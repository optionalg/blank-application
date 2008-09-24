class CreateGenericItems < ActiveRecord::Migration
  def self.up  
    subqueries = Array.new
    [:article, :image, :artic_file, :audio, :video, :publication].each do |model|
      table_name = model.to_s.pluralize
      model_name = model.to_s.classify
      subqueries << %{
        SELECT
          '#{model_name}' as item_type,
          id,
          user_id,
          title,
          description,
          created_at,
          updated_at,
          ( SELECT COUNT(*)
           FROM comments
           WHERE
            #{table_name}.id = comments.commentable_id AND
            comments.commentable_type = '#{model_name}'
           ) AS number_of_comments,
          ( SELECT GROUP_CONCAT(workspaces.name)
            FROM items, workspaces
            WHERE
              #{table_name}.id = items.itemable_id AND
              items.itemable_type = '#{model_name}' AND
              workspaces.id = items.workspace_id
          ) AS workspaces,
          ( SELECT AVG(rating)
            FROM ratings
            WHERE
              #{table_name}.id = ratings.rateable_id AND
              ratings.rateable_type = '#{model_name}'
            GROUP BY rateable_id
          ) AS average_rate
        FROM #{table_name} }
    end
    
    execute "CREATE OR REPLACE VIEW generic_items AS #{subqueries.join(' UNION ALL ')}"
  end

  def self.down
    execute('DROP VIEW generic_items;')
  end
end
