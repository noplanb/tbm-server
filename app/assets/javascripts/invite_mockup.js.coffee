# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  ph = new PhoneController()
  ph.initPhones()
  
  # buttons = [{name:"button1", action:"b1_action"},{name:"button2", action:"b2_action"}]
  # m = new Modal({phoneView: phoneViews[0], title:"title", buttons: buttons, message:"This is my long long long long message to you oo ooo ooo", })
  # m.addModal()


# ===================
# = PhoneController =
# ===================
class window.PhoneController
  
  @instance: false
  
  constructor: ->
    return PhoneController.instance if PhoneController.instance
    @phones = ({ownerInfoData: $(p), phoneDiv: $($(p).find(".phone")), smsDiv: $($(p).find(".sms")), phoneIndex: i} for p, i in $(".phoneCol")) 
    @phones = ($.extend(p, phoneOwnerInfo: @phoneOwnerInfo(p.ownerInfoData)) for p in @phones)
    PhoneController.instance = @  
  
  phoneOwnerInfo: (od) =>
    {
      first_name: $(od).data("last_name")
      last_name: $(od).data("first_name")
      mobile_number: $(od).data("mobile_number")
      device_platform: $(od).data("device_platform")
    } 
    
  initPhones: => @initPhone(phone) for phone in @phones    
  
  initPhone: (phone) =>
    $.extend(phone, user: @getUser(phone))
    $.extend(phone, friends: @getFriends(phone))
    phone.phoneView = new PhoneView phone
    phone.smsView = new SmsView phone
    if phone.user and phone.user.device_platform
      phone.view = new HomeView phone
    else
      phone.view = new NoAppView phone 
  
  getUser: (phone) =>
    response = $.ajax {
      data: phone.phoneOwnerInfo
      url: "reg/get_user"
      async: false
    }
    if $.isEmptyObject(response.responseJSON) then null else response.responseJSON
    
  getFriends: (phone) =>
    return [] unless phone.user
    r = $.ajax {
      data: {mkey:phone.user.mkey}
      url: "reg/get_friends"
      async:false
    }
    r.responseJSON
  
  hasApp: (user) => user.device_platform
    
  #-------
  # Events
  #-------
  menuCloseClick: (phoneIndex) => @phones[phoneIndex].view.hideActionMenu()
  
  menuOpenClick: (phoneIndex) => @phones[phoneIndex].view.showContactsMenu()
  
  inviteClick: (phoneIndex) => 
    p = @phones[phoneIndex]
    p.view.hideActionMenu()
    p.view.showContactsMenu()
  
  inviteeClick: (phoneIndex, contactIndex) =>
    p = @phones[phoneIndex]
    p.view.hideContactsMenu()
    contact = Contacts.contactList[contactIndex]
    invitee = @invite(p, contact)
    if @hasApp(invitee) then @sendInviteNotification() else @sendInviteSms()
  
  invite: (phone, contact) => 
    params = {
      mkey: phone.user.mkey
      invitee: contact
    }
    console.dir params
    response = $.ajax {
      url: "invitation/invite"
      data: params
      async: false
    }
    response.responseJSON
  
  sendInviteSms: =>
    p = @phones[1]
    p.smsView.clear()
    p.smsView.addSms from: @phones[0].user.first_name, msg:"Please add me on Zazo", onclick:"PhoneController.instance.installApp(1)"   
  
  sendInviteNotification: => 
    
  benchClick: (phoneIndex) => alert "Bench"
  
  contactsCloseClick: (phoneIndex) => @phones[phoneIndex].view.hideContactsMenu()
  
  installApp: (phoneIndex) =>
    p = @phones[phoneIndex]
    p.regView = new RegisterView p
    
  registerSubmit: (phoneIndex) =>
    @sendRegistration(phoneIndex)
    @initPhones()
  
  sendRegistration: (phoneIndex) =>
    p = @phones[phoneIndex]
    r = $.ajax {
      url: "reg/reg"
      data: (user: p.phoneOwnerInfo)
      async: false
    }
    p.user = r.responseJSON
    
    
# =============
# = PhoneView =
# =============
class window.PhoneView
	
  @PHONE_DIM: {width:200, height:300}
  @GUTTER: 5
  
  constructor: (options={}) ->
    {@phoneDiv} = options
    @sizePhoneDiv();

  sizePhoneDiv: =>
    @phoneDiv.css {width:"#{PhoneView.PHONE_DIM.width}px", height:"#{PhoneView.PHONE_DIM.height}px"}


# ================
# = RegisterView =
# ================
class RegisterView
  constructor: (options) ->
    {@phoneDiv} = options
    @addRegHtml()
  
  regHtml: =>
    """
    <div class="reg">
      <table class="form">
        <tr><td colspan="2" class="title centered">SIGN UP</td></tr>
        <tr><td class="title">First Name:</td><td>Barbara</td></tr>
        <tr><td class="title">Last Name:</td><td>Boxer</td></tr>
        <tr><td class="title">Phone:</td><td>bb</td></tr>
        <tr><td colspan="2" class="button centered" onclick="PhoneController.instance.registerSubmit(1)">Submit</td></tr>
      </table>
    </div>
    """
    
  addRegHtml: =>
    @phoneDiv.find("*").remove()
    @phoneDiv.append @regHtml()
  
  
# ============
# = HomeView =
# ============
class HomeView
  
  constructor: (options) ->
    {@phoneIndex, @phoneDiv, @user, @friends} = options
    @setupHomeView()
  
  setupHomeView: () =>
    @clearPhoneDiv()
    @addActionBar()
    @addActionMenu()
    @addContactsMenu()
    @setupFriendGrid()
  
  clearPhoneDiv: =>
    @phoneDiv.find("*").remove()
    
  actionBarHtml: => 
    """
    <div class="actionBar">
      <span class="actionMenuIcon" onclick="PhoneController.instance.menuOpenClick(#{@phoneIndex})">...</span>
    </div>
    <div class="friendGrid"></div>
    """
    
  addActionBar: =>
    @phoneDiv.append @actionBarHtml()
    
  addActionMenu: => 
    options = {
    closeClick: "PhoneController.instance.menuCloseClick(#{@phoneIndex})"
    items: [
      {text: 'Invite', action: "PhoneController.instance.inviteClick(#{@phoneIndex})"}
      {text: 'Bench', action: "PhoneController.instance.benchClick(#{@phoneIndex})"}
    ]
    }
    @phoneDiv.append (new ActionMenu(options)).menu
    @actionMenu = $(@phoneDiv.find(".actionMenu"))
    @hideActionMenu()   
    
  hideActionMenu: => @actionMenu.hide()
  showActionMenu: => @actionMenu.show()
    
  addContactsMenu: =>
    @contacts = new Contacts phoneIndex: @phoneIndex
    @phoneDiv.append @contacts.contactsMenu()
    @contactsMenu = $(@phoneDiv.find(".contactsMenu"))
    @contactsMenu.hide()
    
  showContactsMenu: => @contactsMenu.show()
  hideContactsMenu: => @contactsMenu.hide()  
    
  setupFriendGrid: =>
    @addFriendDivs()
    @populateFriendDivs()
    @sizeFriendDivs()
    @positionFriendDivs()
    
  friendDivHtml: (n) =>  
    index = ""
    if n==4 
      index = "center" 
    else if n > 4 
      index = n-1 
    else 
      index = n 
    """
    <div class="friend" id="friend#{n}" data-i="#{n}" data-index="#{index}"></div>
    """
  
  friendContentsHtml: (friend) =>
    if friend
      """
      <div class="friendName">#{friend.first_name}</div>
      """
    else
      """
      <div class="plus">+</div>
      """
        
  addFriendDivs: =>
    @addFriendDiv(i) for i in [0..8]
  
  addFriendDiv: (i) =>
    @phoneDiv.find(".friendGrid").append @friendDivHtml(i)
  
  populateFriendDivs: =>
    @populateFriendDiv(fd) for fd in @phoneDiv.find(".friend")
  
  populateFriendDiv: (friendDiv) =>
    friendDiv = $(friendDiv)
    i = friendDiv.data("index")
    return if i == "center"
    friend = @friends[i]
    friendDiv.append @friendContentsHtml(friend)
  
  sizeFriendDivs: =>
    w = (PhoneView.PHONE_DIM.width - (4 * PhoneView.GUTTER)) / 3
    h = Math.floor(w * 4 / 3)
    $(".friend").css {width:"#{w}px", height:"#{h}px"}
  
  positionFriendDivs: => 
    @positionFriendDiv(div) for div in @phoneDiv.find ".friend"
  
  positionFriendDiv: (div) => 
    i = $(div).data "i"
    row = Math.floor(i / 3)
    col = i%3
    top = (row + 1) * PhoneView.GUTTER + row * $(div).height()
    left = (col + 1) * PhoneView.GUTTER + col * $(div).width()
    $(div).css {top: "#{top}px", left:"#{left}px"}
  

# ============
# = Contacts =
# ============
class window.Contacts
  @contactList: [
    {first_name:"Barbara", last_name:"Boxer", mobile_number:"bb"}
  ]
  
  constructor: (options) ->
    {@phoneIndex} = options  
    
  contactsMenu: =>
    closeClick = "PhoneController.instance.contactsCloseClick(#{@phoneIndex})"
    @items = ({text: "#{c.first_name} #{c.last_name}", action: "PhoneController.instance.inviteeClick(#{@phoneIndex}, #{i})"} for c,i in Contacts.contactList)
    (new ActionMenu {closeClick: closeClick, items: @items, class: "contactsMenu"}).menu()
    

# =============
# = NoAppView =
# =============
class NoAppView
  constructor: (options) ->
    {@phoneDiv} = options
    @addNoAppHtml()
  
  noAppHtml: =>
    """
    <div class="noApp">TBM Not Installed</div>
    """
    
  addNoAppHtml: =>
    @phoneDiv.find("*").remove()
    @phoneDiv.append @noAppHtml()
    
    
# =========
# = Modal =
# =========
class Modal
  
  constructor: (options={}) ->
    {@phoneView, @title, @message, @buttons} = options
    @phoneDiv = @phoneView.phoneDiv
    @phoneDiv = $(@phoneDiv)
   
  modalHtml: => 
    """
    <div class="modal">
      <div class="title">#{@title}</div>
      <div class="message">#{@message}</div>
      <div class="buttons"></div>
    </div>
    """
  
  buttonsHtml: =>
    (@buttonHtml(button) for button in @buttons).join(" | ")
  
  buttonHtml: (button) =>
    """
    <span class="button" onclick="#{button.action}">#{button.name}</span>
    """
  
  addButtons: =>
    @phoneDiv.find(".modal .buttons").append @buttonsHtml()
    
  sizeModal: =>
    width = Math.floor(0.66*PhoneView.PHONE_DIM.width)
    $(".modal").css {width: "#{width}px"}
  
  addModal: =>
    @removeModal()
    @phoneDiv.prepend @modalHtml()
    @addButtons()
    @sizeModal()
  
  removeModal: =>
    @phoneDiv.find(".modal").remove()
    
# ==============
# = ActionMenu =
# ==============
class ActionMenu
  
  constructor: (options) ->
    {@closeClick, @items, @class} = options
    @class ||= "actionMenu"
  
  menu: =>
    @menu = $.parseHTML("<div class='#{@class} menuView'><div onclick='#{@closeClick}' class='closeX'>X</div></div>")[0]
    @menu = $(@menu)
    @menu.append @itemHtml(item) for item in @items
    @sizeMenu()
      
  sizeMenu: =>
    width = Math.floor(0.66*PhoneView.PHONE_DIM.width)
    @menu.css {width: "#{width}px"}
    @menu
    
  itemHtml: (item) =>
    """
    <div class="item" onclick="#{item.action}">#{item.text}</div>
    """
  
  hideMenu: =>
    @menu.hide()
  
# =======
# = SMS =
# =======
class SmsView
  
  constructor: (options={}) ->
    {@smsDiv} = options
    @sizeSms()
  
  sizeSms: =>
    @smsDiv.css {width: "#{PhoneView.PHONE_DIM.width - 16}px"}
  
  addSms: (msg) => 
    @smsDiv.append @msgHtml(msg)
  
  clear: =>
    @smsDiv.find(".message").remove()
  
  msgHtml: (msg) =>
    """
    <div class="message">
      <div class="from">#{msg.from}:</div>
      <div class="msg #{if msg.onclick then "link" else ""}" onclick=#{msg.onclick}>#{msg.msg}</div>
    </div>
    """