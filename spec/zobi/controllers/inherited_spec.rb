# encoding: utf-8
require 'spec_helper'

describe Inherited::FoosController, type: :controller do
  render_views

  let!(:foo) { Foo.create!(name: 'public foo', published: true) }

  describe '#index' do
    it 'should return a collection of Foos' do
      get :index
      controller.collection.should include foo
    end
  end

  describe '#new' do
    subject { get :new }

    it 'should return a new foo resource' do
      subject
      controller.send(:resource).new_record?.should be_truthy
    end

    it 'should render template new' do
      expect(subject).to render_template(:new)
    end
  end

  describe '#edit' do
    subject { get :edit, id: foo.id }

    it 'should return the requested foo resource' do
      subject
      controller.send(:resource).should eq foo
    end

    it 'should render template edit' do
      expect(subject).to render_template(:edit)
    end
  end

  describe '#create' do
    context 'no block given' do
      subject { post :create, foo: {name: 'foo', category: 'bar', published: true, unknown: 'param'} }

      it 'should use Parameters class to filter params' do
        Foo.should_receive(:new)
          .with({'name' => 'foo', 'category' => 'bar', 'published' => true})
          .and_return foo
        subject
      end

      it 'should redirect to resource path by default' do
        expect(subject).to redirect_to(inherited_foo_path(Foo.last))
      end
    end

    context 'block given' do
      subject { post :create_with_block, foo: {name: 'foo', category: 'bar', published: true, unknown: 'param'} }

      it 'should call yield with ressource if block given' do
        subject
        expect(response.body).to eq({r: Foo.last.as_json}.to_json)
      end
    end
  end

  describe '#update' do
    context 'no block given' do
      subject { put :update, id: foo.id, foo: {name: 'foo', category: 'bar', published: true, unknown: 'param'} }
      it 'should use Parameters class to filter params' do
        Foo.should_receive(:find).with(foo.id.to_s).and_return foo
        foo.should_receive(:update_attributes)
          .with({'name' => 'foo', 'category' => 'bar', 'published' => true})
          .and_return foo
        subject
      end

      it 'should redirect to resource path by default' do
        expect(subject).to redirect_to(inherited_foo_path(foo.id))
      end
    end

    context 'block given' do
      subject { put :update_with_block, id: foo.id, foo: {name: 'foo', category: 'bar', published: true, unknown: 'param'} }

      it 'should call yield with ressource if block given' do
        subject
        expect(response.body).to eq({r: Foo.last.as_json}.to_json)
      end
    end
  end

  describe '#destroy' do
    context 'no block given' do
      subject { delete :destroy, id: foo.id }
      it 'should redirect to collection_path' do
        expect(subject).to redirect_to(inherited_foos_path)
      end
    end

    context 'block given' do
      subject { delete :destroy_with_block, id: foo.id }

      it 'should call yield with ressource if block given' do
        resp = {r: Foo.last.as_json}
        subject
        expect(response.body).to eq(resp.to_json)
      end
    end
  end
end
