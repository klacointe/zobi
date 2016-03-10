# encoding: utf-8
require 'spec_helper'

class AllBehavior
end

class NoBehavior
end

class NoBehaviorController < ActionController::Base
  extend Zobi
  behaviors *[]
end

class AllBehaviorsController < ActionController::Base
  extend Zobi
  behaviors *Zobi::BEHAVIORS
end

describe Zobi do

  it 'should be a module' do
    Zobi.kind_of?(Module).should be_truthy
  end

  it 'should define list of available behaviors' do
    Zobi::BEHAVIORS.should eq [:inherited, :scoped, :included, :paginated,
                              :controlled_access, :decorated]
  end

  Zobi::BEHAVIORS.each do |behavior|
    it "should return if #{behavior} is included" do
      AllBehaviorsController.behavior_included?(behavior).should be_truthy
    end

    it "should know if #{behavior} is not included" do
      NoBehaviorController.behavior_included?(behavior).should be_falsy
    end
  end

  it 'should define zobi_resource_class (and resource_class alias)' do
    expect(AllBehaviorsController.new.zobi_resource_class).to eq AllBehavior
    expect(AllBehaviorsController.new.resource_class).to eq AllBehavior
  end

  it 'should define zobi_resource_name (and resource_name alias)' do
    expect(AllBehaviorsController.new.zobi_resource_name).to eq 'AllBehavior'
    expect(AllBehaviorsController.new.resource_name).to eq 'AllBehavior'
  end

  it 'should define zobi_resource_key (and resource_key alias)' do
    expect(AllBehaviorsController.new.zobi_resource_key).to eq 'all_behavior'
    expect(AllBehaviorsController.new.resource_key).to eq 'all_behavior'
  end
end
