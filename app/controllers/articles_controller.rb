class ArticlesController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:show, :index, :new_feedback]

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    unless @article.present?
      if params[:id] && lookup_context.exists?(params[:id], 'static')
        render template: 'static/main'
      else
        redirect_to feedback_path, notice: t('.article_doesnt_exist'), flash: {url: request.original_url}
      end
    end
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    article_params['permalink'] ||= article_params['title'].mb_chars.parameterize.gsub(/^\//, '')
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render action: 'show', status: :created, location: @article }
      else
        format.html { render action: 'new' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { render action: 'show', notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url }
      format.json { head :no_content }
    end
  end

  def new_feedback
  end

  def feedback
    GeneralMailer.feedback(feedback_params[:email], feedback_params[:subject], simple_format(feedback_params[:body])).deliver
    redirect_to store_path, flash: {success: 'Спасибо за ваше внимание.'}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find_by(permalink: params[:id])
      #redirect_to store_path, notice: t('.article_doesnt_exist') unless @article
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :body, :author, :permalink)
    end

    def feedback_params
      params.require(:feedback).permit(:email, :subject, :body)
    end
end
