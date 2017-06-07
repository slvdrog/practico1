require 'rubygems'
require 'sinatra'
require 'slim'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Client
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :boxes
  has n, :documents, through: :boxes
end

class Box
  include DataMapper::Resource

  property :id, Serial
  property :serial, String
  property :created_at, DateTime

  belongs_to :client
  has n, :documents
end

class Document
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :created_at, DateTime

  belongs_to :box
end

DataMapper.auto_upgrade!
Client.auto_upgrade!
Box.auto_upgrade!
Document.auto_upgrade!


get '/' do
  slim :index
end

get '/clients' do
  @clients = Client.all
  slim :clients
end

get '/client/:id' do
  @client = Client.get(params[:id])
  @recent_documents = @client.documents.last(5)
  # Aca deben consultar los ultimos 5 documentos almacenados recientemente VEEERRRRRRRRRRRRRRRRRR

  slim :client
end

post '/client/new' do
  client = Client.new(:name => params[:name])
  if client.save
   redirect "/"
	else
	 p 'Algo salio malo'
	end
end

get '/client/:id/delete' do
  client = Client.get(params[:id])
  client.destroy

  redirect '/clients'
end

post '/client/:id/box/new' do
  client = Client.get(params[:id])
  box = client.boxes.new(serial: params[:serial], created_at: Time.now)
  if box.save
    redirect "/client/#{client.id}"
  else
    redirect "/client/#{client.id}"
  end
end

get '/client/:client_id/box/:id/delete' do
  client = Client.get(params[:client_id])
  box = client.boxes.get(params[:id])
  box.destroy

  redirect "/client/#{client.id}"
end

get '/client/:client_id/box/:id' do
  client = Client.get(params[:client_id])
  @box = client.boxes.get(params[:id])
  slim :box
end

post '/client/:client_id/box/:box_id/document/new' do
  client = Client.get(params[:client_id])
  box = client.boxes.get(params[:box_id])
  document = box.documents.new(name: params[:name], created_at: Time.now)
  if document.save
    redirect "/client/#{client.id}/box/#{box.id}"
  else
    redirect "/client/#{client.id}/box/#{box.id}"
  end
end

get '/client/:client_id/box/:box_id/document/:id/delete' do
  client = Client.get(params[:client_id])
  box = client.boxes.get(params[:box_id])
  document = box.documents.get(params[:id])

  document.destroy

  redirect "/client/#{client.id}/box/#{box.id}"

  # Borrado de un documento, usando la herencia de la ruta
end
