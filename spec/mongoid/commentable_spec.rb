require 'spec_helper'

describe Mongoid::Commentable do
  
  describe Comment do
   
    context 'creating new comment' do
      subject {CommentableModel.new.create_comment!(:author => 'Author', :text => 'test') }
      its(:class){should == Comment}
      its(:author){should == 'Author'}
      its(:text){should == 'test'}
      specify{subject.path.should == "root.#{subject.id}"}
   end

    context 'replying to a comment' do
      before do
        @commentable_model = CommentableModel.new
        3.times{|i| @commentable_model.create_comment!(nil)}
        @parent = @commentable_model.comments.first
      end

      subject{@child = @commentable_model.create_comment!(:parent => @parent.id.to_s)}
      specify{subject.path.should == "root.#{@parent.id}.#{subject.id}"}
    end

    context 'marking comment as deleted' do
      before do
        @comment = CommentableModel.new.create_comment!(nil)
        @comment.remove
      end
      subject {@comment}
      its(:deleted_at){should_not be_nil}
      its(:deleted?){should be_true}
    end

    context 'getting branch' do
      before do
        @commentable_model = CommentableModel.new
        @comment1 = @commentable_model.create_comment!(nil)
        @comment2 = @commentable_model.create_comment!(nil)
        @child1 = @commentable_model.create_comment!(:parent => @comment1.id.to_s)
        @child2 = @commentable_model.create_comment!(:parent => @child1.id.to_s)
      end
      subject{@commentable_model}
      specify{subject.branch_for(@comment1.id).should == [@comment1,@child1,@child2]}
    end

    describe "#comments_list" do
      let(:commentable_model) { CommentableModel.new }
      let!(:comment_a) { commentable_model.create_comment!(:author => 'Author', :text => 'comment_a') }
      let!(:comment_b) { commentable_model.create_comment!(:author => 'Author', :text => 'comment_b') }
      before do
        comment_a.update_attribute(:created_at, 2.days.ago)
      end
      context "with default sort" do
        subject { commentable_model.comments_list }
        its(:first) { should eql(comment_a) }
        its(:last) { should eql(comment_b) }
      end
      context "with :desc sort" do
        subject { commentable_model.comments_list(:desc) }
        its(:first) { should eql(comment_b) }
        its(:last) { should eql(comment_a) }
      end
    end
  end
end
