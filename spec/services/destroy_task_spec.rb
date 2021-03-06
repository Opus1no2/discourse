require 'rails_helper'

describe DestroyTask do

  describe 'destroy topics' do
    let!(:c) { Fabricate(:category) }
    let!(:t) { Fabricate(:topic, category_id: c.id) }
    let!(:p) { Fabricate(:post, topic_id: t.id) }
    let!(:c2) { Fabricate(:category) }
    let!(:t2) { Fabricate(:topic, category_id: c2.id) }
    let!(:p2) { Fabricate(:post, topic_id: t2.id) }

    it 'destroys all topics in a category' do
      before_count = Topic.where(category_id: c.id).count
      DestroyTask.destroy_topics(c.slug)
      expect(Topic.where(category_id: c.id).count).to eq before_count - 1
    end

    it "doesn't destroy system topics" do
      DestroyTask.destroy_topics(c2.slug)
      expect(Topic.where(category_id: c2.id).count).to eq 1
    end

    it 'destroys topics in all categories' do
      DestroyTask.destroy_topics_all_categories
      expect(Post.where(topic_id: [t.id, t2.id]).count).to eq 0
    end
  end

  describe 'private messages' do
    let!(:pm) { Fabricate(:private_message_post) }
    let!(:pm2) { Fabricate(:private_message_post) }

    it 'destroys all private messages' do
      DestroyTask.destroy_private_messages
      expect(Topic.where(archetype: "private_message").count).to eq 0
    end
  end

  describe 'groups' do
    let!(:g) { Fabricate(:group) }
    let!(:g2) { Fabricate(:group) }

    it 'destroys all groups' do
      before_count = Group.count
      DestroyTask.destroy_groups
      expect(Group.where(automatic: false).count).to eq 0
    end

    it "doesn't destroy default groups" do
      before_count = Group.count
      DestroyTask.destroy_groups
      expect(Group.count).to eq before_count - 2
    end
  end

  describe 'users' do
    let!(:u) { Fabricate(:user) }
    let!(:u2) { Fabricate(:user) }
    let!(:a) { Fabricate(:admin) }

    it 'destroys all non-admin users' do
      DestroyTask.destroy_users
      expect(User.where(admin: false).count).to eq 0
      expect(User.count).to eq 2 #system + 1 other admin
    end
  end

  describe 'stats' do
    it 'destroys all site stats' do
      DestroyTask.destroy_stats
    end
  end
end
