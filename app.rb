# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'

def read(id)
  csv_table = CSV.table('memos.csv', headers: true)
  csv_table.each do |row|
    if row[:id] == id.to_i
      @title = row[:title]
      @content = row[:content]
    end
  end
end

def write(id, title, content)
  @id = id
  @title = title
  @content = content
  CSV.open('memos.csv', 'a') do |csv|
    csv << [@id, @title, @content]
  end
end

def delete(id)
  @id = id
  csv_table = CSV.table('memos.csv', headers: true)
  csv_table.delete_if { |row| row[:id] == id.to_i }
  CSV.open('memos.csv', 'w') do |csv|
    csv << %w[id title content]
    csv_table.each do |row|
      csv << row
    end
  end
end

def rewrite(id, title, content)
  @id = id
  csv_table = CSV.table('memos.csv', headers: true)
  csv_row = csv_table.find { |row| row[:id] == id.to_i }
  csv_row[:title] = title
  csv_row[:content] = content
  CSV.open('memos.csv', 'w') do |csv|
    csv << %w[id title content]
    csv_table.each do |row|
      csv << row
    end
  end
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  @csv = CSV.read('memos.csv', headers: true)
  erb :top
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @content = params[:memo]
  write(@content.object_id, params[:name], @content)
  @csv = CSV.read('memos.csv', headers: true)
  erb :top
end

get '/memos/:id' do |id|
  @id = id
  read(@id)
  erb :show
end

delete '/memos/:id' do |id|
  delete(id)
  erb :delete
end

get '/memos/:id/edit' do |id|
  @id = id
  read(@id)
  erb :edit
end

patch '/memos/:id' do |id|
  @id = id
  rewrite(@id, params[:name], params[:memo])
  erb :edit_complete
end
