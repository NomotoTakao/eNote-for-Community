
class ExecuteInitialTrigger < ActiveRecord::Migration
  def self.up
    # 現在のプロジェクトの、トリガーファイルの名前リストを取得する。
    files = Dir['db/trigger/*.trigger']

    # 各々のファイルを実行する。
    files.each do |file|
      execute File.open(file, "r").read
    end
  end

  def self.down
    
  end
end
