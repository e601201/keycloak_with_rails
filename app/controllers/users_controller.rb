class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    redirect_to root_path if current_user.nil? || current_user.id.to_s != params[:id]
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    if @user.valid?
      p '登録されたユーザー情報に問題はありません'
      p 'このままkeyclaokへの登録を開始します。'
      access_token = keycloak_admin_login
      res = user_register_by_keycloak(access_token, @user)
      if res[:code] == '201'
        p 'keycloakDB登録完了！！'
        if @user.save!
          p 'railsDB登録完了！！'
          redirect_to user_url(@user), notice: 'User was successfully created.'
        else
          render :new, status: :unprocessable_entity
        end
      else
        p 'keycloak側でエラーが発生しました。'
        p "code:#{res[:code]} message: #{res[:message]}"
        flash[:alert] = "エラーコード:#{res[:code]} エラーメッセージ: #{res[:message]}"
        render :new, status: :unprocessable_entity
      end
    else
      p '登録フォームに問題があります'
      p @user.errors.full_messages
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # レコードが見つからない場合の処理
      flash[:alert] = 'User not found'
      redirect_to root_path # または適切な404エラーページへのリダイレクト
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:user_name, :first_name, :last_name, :email, :password, :password_confirmation)
    end

    def keycloak_admin_login
      url = URI.parse('https://sso.koumi-test.com/realms/master/protocol/openid-connect/token')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true  # TODO: HTTPSを使用する場合はこれを設定
      headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'cache-control' => 'no-cache'
      }
      data = {
        'grant_type' => 'password',
        'username' => 'admin',
        'password' => 'admin',
        'client_id' => 'admin-cli'
      }
      request = Net::HTTP::Post.new(url.path, headers)
      request.set_form_data(data)
      response = http.request(request)
      res = JSON.parse(response.body)
      res['access_token']
    end

    def user_register_by_keycloak(access_token, user)
      url = URI('https://sso.koumi-test.com/admin/realms/koumi-realm/users')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true  # TODO: HTTPSを使用する場合はこれを設定
      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}"
      request.body = JSON.dump(
        {
          "username": user.user_name,
          "enabled": true,
          "email": user.email,
          "firstName": user.first_name,
          "lastName": user.last_name,
          "credentials": [{
            "type": 'password',
            "value": user.password,
            "temporary": false
          }]
        }
      )
      response = http.request(request)
      { code: response.code, message: response.message }
    end
end
