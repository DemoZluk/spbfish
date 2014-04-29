class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    @bookmarks = if order_params.match 'product_id'
      if order_params.match 'desc'
        current_user.bookmarks.joins{product}.order{product.title.desc}
      else
        current_user.bookmarks.joins{product}.order{product.title}
      end
    else
      current_user.bookmarks.order(order_params)
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
  end

  # GET /bookmarks/new
  def new
    @bookmark = Bookmark.new
  end

  # GET /bookmarks/1/edit
  def edit
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = Bookmark.new(bookmark_params)

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to @bookmark, notice: 'Bookmark was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bookmark }
      else
        format.html { render action: 'new' }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  def bookmark_product
    index
    @product = Product.find_by(permalink: params[:product])
    if @bookmark = Bookmark.find_by(product_id: @product.id, user_id: current_user.id)
      @bookmark.destroy
      respond_to do |format|
        format.html {redirect_to :back, notice: 'Product deleted from bookmarks'}
        format.js {render action: :destroy}
        format.json {render product_id: @product.id, status: :deleted_from_bookmarks}
      end
    else
      @bookmark = Bookmark.new(product_id: @product.id, user_id: current_user.try(:id))

      respond_to do |format|
        if @bookmark.save
          format.html {redirect_to :back, notice: 'Product bookmarked'}
          format.js
          format.json {render product_id: @product.id, status: :success}
        else
          format.html {redirect_to :back, notice: 'Fail'}
        end
      end
    end
  end

  # PATCH/PUT /bookmarks/1
  # PATCH/PUT /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to @bookmark, notice: 'Bookmark was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    @product = @bookmark.product
    @bookmark.destroy
    respond_to do |format|
      format.html { redirect_to store_path }
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bookmark
      @bookmark ||= Bookmark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bookmark_params
      params.require(:bookmark).permit(:product_id)
    end

    def order_params
      desc = ['asc', 'desc'].include?(params[:type]) ? params[:type] : 'desc'
      @sort = Bookmark.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
      @sort += ' ' + desc
    end
end
