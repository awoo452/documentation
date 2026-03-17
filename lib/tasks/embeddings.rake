namespace :embeddings do
  desc "Backfill embeddings for documents"
  task backfill: :environment do
    Document.find_each do |doc|
      doc.generate_embedding!
    end
  end
end
