class ItemsController < ApplicationController
  before_action :require_user_logged_in

  def new
    @items = []  #@items をカラの配列として初期化
                 #初期化しないと View 側で @items にアクセスしたときに nil となってしまい、エラーが発する

    @keyword = params[:keyword]  #フォームから送信される検索ワードを取得
    if @keyword.present?
      results = RakutenWebService::Ichiba::Item.search({
        keyword: @keyword,
        imageFlag: 1,
        hits: 20,
      })

      results.each do |result|
         # 扱い易いように Item としてインスタンスを作成する（保存はしない）
        item = Item.new(read(result))
        @items << item  #item を [] に追加
      end
    end
  end

  private

  def read(result)  #必要な値を読み出して、最後にハッシュとして return
    code = result['itemCode']
    name = result['itemName']
    url = result['itemUrl']
    image_url = result['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')
      #第一引数を見つけ出して、第二引数に置換するメソッド⇒第ニ引数に '' とカラ文字を入れているので、見つけたら削除する
      #画像 URL 末尾に含まれる ?_ex=128x128 を削除

    {
      code: code,
      name: name,
      url: url,
      image_url: image_url,
    }
  end
end
