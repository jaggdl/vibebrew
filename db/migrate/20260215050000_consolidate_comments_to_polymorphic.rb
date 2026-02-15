class ConsolidateCommentsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Create the polymorphic comments table
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    add_index :comments, [ :commentable_type, :commentable_id, :created_at ], name: "index_comments_on_commentable_and_created_at"

    # Migrate recipe comments
    if table_exists?(:recipe_comments)
      execute <<-SQL.squish
        INSERT INTO comments (commentable_type, commentable_id, user_id, body, published, created_at, updated_at)
        SELECT 'Recipe', recipe_id, user_id, body, COALESCE(published, false), created_at, updated_at
        FROM recipe_comments
      SQL
    end

    # Migrate coffee bean comments (if table exists)
    if table_exists?(:coffee_bean_comments)
      execute <<-SQL.squish
        INSERT INTO comments (commentable_type, commentable_id, user_id, body, published, created_at, updated_at)
        SELECT 'CoffeeBean', coffee_bean_id, user_id, body, published, created_at, updated_at
        FROM coffee_bean_comments
      SQL
    end

    # Drop old tables
    drop_table :recipe_comments if table_exists?(:recipe_comments)
    drop_table :coffee_bean_comments if table_exists?(:coffee_bean_comments)
  end

  def down
    # Restore recipe_comments table
    create_table :recipe_comments do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.boolean :published

      t.timestamps
    end

    # Restore coffee_bean_comments table
    create_table :coffee_bean_comments do |t|
      t.references :coffee_bean, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    # Migrate back from polymorphic
    Comment.where(commentable_type: "Recipe").find_each do |comment|
      execute <<-SQL.squish
        INSERT INTO recipe_comments (recipe_id, user_id, body, published, created_at, updated_at)
        VALUES (#{comment.commentable_id}, #{comment.user_id}, #{connection.quote(comment.body)}, #{comment.published}, '#{comment.created_at.to_fs(:db)}', '#{comment.updated_at.to_fs(:db)}')
      SQL
    end

    Comment.where(commentable_type: "CoffeeBean").find_each do |comment|
      execute <<-SQL.squish
        INSERT INTO coffee_bean_comments (coffee_bean_id, user_id, body, published, created_at, updated_at)
        VALUES (#{comment.commentable_id}, #{comment.user_id}, #{connection.quote(comment.body)}, #{comment.published}, '#{comment.created_at.to_fs(:db)}', '#{comment.updated_at.to_fs(:db)}')
      SQL
    end

    drop_table :comments
  end
end
