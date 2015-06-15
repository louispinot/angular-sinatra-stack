class AddNaToCompanySegment < ActiveRecord::Migration
  def self.up
    # ALTER TYPE ... ADD VALUE cannot be executed inside a transaction block,
    # yet all AR migrations are wrapped in a transaction. the `execute 'END'`
    # and `execute 'BEGIN'` statements allow the 'ADD VALUE' statement to be
    # executed outside of a block
    execute "END"
    execute <<-SQL
      ALTER TYPE company_segment ADD VALUE IF NOT EXISTS 'NA'
    SQL
    execute "BEGIN"
  end
end
