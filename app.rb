# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "csv"

def read(id)
  @id = id
  csv = CSV.read("memos.csv", headers: true)
  csv.each do |row|
    if row["id"] == @id
      @title = row["title"]
      @content = row["content"]
    end
  end
end

def write(id, title, content)
  @id = id
  @title = title
  @content = content
  CSV.open("memos.csv", "a") do |csv|
    csv << [@id, @title, @content]
  end
end

def delete(id)
  @id = id
  csv_table = CSV.table("memos.csv", headers: true)
  csv_table.by_row!
  csv_table.delete_if { |row| row.field?(@id.to_i) }
  CSV.open("memos.csv", "w") do |csv|
    csv << ["id", "title", "content"]
    csv_table.each do |row|
      csv << row
    end
  end
end

def rewrite(id, title, content)
  delete(id)
  write(id, title, content)
end

get "/" do
  redirect to("/memos")
end

get "/memos" do
  @csv = CSV.read("memos.csv", headers: true)
  erb :top
end

get "/memos/new" do
  erb :new
end

post "/memos" do
  write(@content.object_id, @params[:name], @params[:memo])
  @csv = CSV.read("memos.csv", headers: true)
  erb :top
end

get "/memos/*/" do |id|
  read(id)
  erb :show
end

delete "/memos/*/" do |id|
  delete(id)
  erb :delete
end

get "/memos/*/edit" do |id|
  read(id)
  erb :edit
end

patch "/memos/*/" do |id|
  rewrite(id, @params[:name], @params[:memo])
  erb :edit_complete
end
