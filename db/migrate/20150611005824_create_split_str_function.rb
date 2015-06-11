class CreateSplitStrFunction < ActiveRecord::Migration
  def up
    sql = <<-SQL
      CREATE FUNCTION SPLIT_STR(
        x VARCHAR(255),
        delim VARCHAR(12),
        pos INT
      )
      RETURNS VARCHAR(255)
      RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
             LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
             delim, '') COLLATE utf8_unicode_ci;
     SQL
     execute sql.squish
  end

  def down
    execute 'DROP FUNCTION SPLIT_STR;'
  end
end
