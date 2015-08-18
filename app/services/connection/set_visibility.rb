class Connection::SetVisibility
  include ActiveModel::Validations

  MASK_MAP = [
    { status: 'established',       mask: [:v, :v] },
    { status: 'hidden_by_creator', mask: [:h, :v] },
    { status: 'hidden_by_target',  mask: [:v, :h] },
    { status: 'hidden_by_both',    mask: [:h, :h] }
  ].freeze

  attr_reader :user, :friend, :visibility, :connection

  validates :user, :friend, :connection, :visibility, presence: true
  validates :visibility, inclusion: { in: %w(hidden visible), message: '%{value} is not a valid visibility state' }, allow_nil: true
  validate :status_not_voided

  def initialize(params, current_user = nil)
    @user       = current_user ? current_user.mkey : find_user(params[:user_mkey])
    @friend     = find_user(params[:friend_mkey])
    @visibility = params[:visibility]
    @connection = Connection.between(user.id, friend.id).first
  end

  def do
    return false unless valid?
    connection.update_attributes status: final_status
  end

  private

  def final_status
    get_from_map applied_status_mask, :status
  end

  def applied_status_mask
    current = get_from_map(connection.status, :mask).dup
    input_status_mask.each_with_index do |k, i|
      current[i] = k unless k.nil?
    end
    current
  end

  def input_status_mask
    mask_key = visibility[0].to_sym
    if connection.creator_id == user.id
      [mask_key, nil] # user is creator
    else
      [nil, mask_key] # user is target
    end
  end

  def get_from_map(by, key)
    find_vector = (key == :mask ? :status : :mask)
    MASK_MAP.find { |l| l[find_vector] == by }[key]
  end

  def find_user(mkey)
    User.find_by mkey: mkey
  end

  #
  # custom validations
  #

  def status_not_voided
    errors.add(:status, 'must be not voided to perform this operation') if connection.status == 'voided'
  end
end
