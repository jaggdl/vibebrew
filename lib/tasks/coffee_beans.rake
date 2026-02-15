namespace :coffee_beans do
  desc "Generate embeddings for all coffee beans that don't have them"
  task generate_embeddings: :environment do
    coffee_beans = CoffeeBean.left_outer_joins(:coffee_bean_vector)
                            .where(coffee_bean_vectors: { id: nil })
                            .where.not(brand: nil)

    puts "Generating embeddings for #{coffee_beans.count} coffee beans..."

    coffee_beans.find_each do |coffee_bean|
      begin
        coffee_bean.find_or_create_vector
        print "."
      rescue => e
        puts "\nError processing CoffeeBean ##{coffee_bean.id}: #{e.message}"
      end
    end

    puts "\nDone!"
  end
end
