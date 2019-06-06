require 'sinatra'
require 'sinatra/reloader'

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
  File.open("memo/#{@id.to_s}", "r") do |file|
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
  if File.exist?("memo/#{@id.to_s}")
    File.open("memo/#{@id.to_s}","r+") do |file|
      file.puts @content
    end
  # 新規作成
  else
    @@id_syms.push(@id_sym)
    File.open("memo/#{@id.to_s}","w") do |file|
      file.puts @content
    end
  end
end

def delete_process(id)
  @id = id
  @id_sym = @id.to_s.to_sym
  @@call_title.delete(@id_sym)
  @@id_syms.delete(@id_sym)
  File.delete("memo/#{@id.to_s}")
end

get '/' do
  erb :top
end

get '/new' do
  erb :new
end

post '/new' do
  @content = @params[:memo]
  write_process(@content.object_id, @params[:name], @content)
  erb :top
end

get '/show/*' do |id|
  read_process(id)
  erb :show
end

delete '/delete/*' do |id|
  delete_process(id)
  erb :delete
end

get '/edit/*' do |id|
  read_process(id)
  erb :edit
end

patch '/edit-compleate/*' do |id|
  write_process(id, @params[:name], @params[:memo])
  erb :edit_complete
end




