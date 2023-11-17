class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show; end

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
      p "このままkeyclaokへ登録します"
      access_token = keycloak_login
      user_register_by_keycloak(access_token)

    else
      p "エラーを返します"
      p @user.errors.full_messages
    end

    User.find_or_create_by(user_params)
    # ユーザーを新規追加するメソッド

    # respond_to do |format|
    #   if @user.save
    #     format.html { redirect_to user_url(@user), notice: "User was successfully created." }
    #     format.json { render :show, status: :created, location: @user }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @user.errors, status: :unprocessable_entity }
    #   end
    # end
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
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

    def keycloak_login
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
      access_token = res["access_token"]
      access_token
    end

    def user_register_by_keycloak(access_token)
      url = URI("https://sso.koumi-test.com/admin/realms/koumi-realm/users")
      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{access_token}"
      request.body = JSON.dump({
        "username": "hogehoge",
        "enabled": true,
        "email": "hogehoge@example.com",
        "credentials": [
          {
            "type": "password",
            "value": "test123",
            "temporary": false
          }
        ]
      })
      response = http.request(request)
      puts response.read_body
    end
end
