# encoding: utf-8
class Inherited::FoosController < ApplicationController
  extend Zobi
  behaviors :inherited, :scoped

  def create
    create!
  end

  def create_with_block
    create! do |r|
      render json: {r: r.as_json} and return
    end
  end

  def update
    update!
  end

  def update_with_block
    update! do |r|
      render json: {r: r.as_json} and return
    end
  end

  def destroy
    destroy!
  end

  def destroy_with_block
    destroy! do |r|
      render json: {r: r.as_json} and return
    end
  end
end
