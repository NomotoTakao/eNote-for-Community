class Data::MainController < ApplicationController
  layout "portal"

  def index
    @pankuzu += "データのインポート/エクスポート"
  end
end
