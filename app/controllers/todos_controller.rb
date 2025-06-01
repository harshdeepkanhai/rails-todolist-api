class TodosController < ApplicationController
  before_action :require_authorization
  before_action :set_todo, only: %i[ show edit update destroy ]

  # GET /todos or /todos.json
  def index
    @todos = Todo.all
  end

  # GET /todos/1 or /todos/1.json
  def show
  end

  # POST /todos or /todos.json
  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        render :show, status: :created, location: @todo
      else
        render json: @todo.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /todos/1 or /todos/1.json
  def update
    respond_to do |format|
      if @todo.update(todo_params)
        render :show, status: :ok, location: @todo
      else
        render json: @todo.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /todos/1 or /todos/1.json
  def destroy
    @todo.destroy!

    respond_to do |format|
      head :no_content
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.expect(todo: [ :description ])
    end

    def require_authorization
      key = request.headers.fetch("Authorization").split(" ").last
      if  key != "api_key2"
        render json: { message: "Invalid API key" }, status: :unauthorized
      end
    end
end
