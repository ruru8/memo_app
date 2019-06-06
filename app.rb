# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"

# 配列確保
@@call_title = {}
@@id_syms = []

def id_process(id)
  @id = id
  @id_sym = @id.to_s.to_sym
end

def read_process(id)
  @id = id
  @id_sym = @id.to_s.to_sym
  @title = @@call_title[@id_sym]
  File.open("memo/#{@id}", "r") do |file|
    @content = file.read
  end
end

def write_process(id, title, content)
  @id = id
  @title = title
  @content = content
  @id_sym = @id.to_s.to_sym
  @@call_title[@id_sym] = @title
  # 編集
  if File.exist?("memo/#{@id}")
    File.open("memo/#{@id}", "r+") do |file|
      file.puts @content
    end
  # 新規作成
  else
    @@id_syms.push(@id_sym)
    File.open("memo/#{@id}", "w") do |file|
      file.puts @content
    end
  end
end

def delete_process(id)
  @id = id
  @id_sym = @id.to_s.to_sym
  @@call_title.delete(@id_sym)
  @@id_syms.delete(@id_sym)
  File.delete("memo/#{@id}")
end

get "/" do
  redirect to('/memos')
end

get "/memos" do
  erb :top
end

get "/memos/new" do
  erb :new
end

post "/memos" do
  @content = @params[:memo]
  write_process(@content.object_id, @params[:name], @content)
  erb :top
end

get "/memos/*/" do |id|
  read_process(id)
  erb :show
end

delete "/memos/*/delete" do |id|
  delete_process(id)
  erb :delete
end

get "/memos/*/edit" do |id|
  read_process(id)
  erb :edit
end

patch "/memos/*/edit-complete" do |id|
  write_process(id, @params[:name], @params[:memo])
  erb :edit_complete
end
