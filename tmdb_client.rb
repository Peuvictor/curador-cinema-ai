require 'uri'
require 'net/http'
require 'json'

class TMDBClient
  # Substitua pelo seu token real gerado no site do TMDB
  TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYTIwMzE3ZDc5NDNhY2I2MmZkOGI0MzdlZGFhNGJlNyIsIm5iZiI6MTc3ODU5MDE0MC4zOTY5OTk4LCJzdWIiOiI2YTAzMjFiY2ZkNDc4ZWFlMzIxZTQ0ZmIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.soB3l-6WvyqwwexPDPmJP9wfn2BOb7M6GTnaZHlaNQM"

  def self.buscar_em_alta
    url = URI("https://api.themoviedb.org/3/trending/movie/week?language=pt-BR")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = "Bearer #{TOKEN}"

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      dados = JSON.parse(response.read_body)

      puts "🎬 **Top 5 Filmes em Alta na Semana:**\n\n"

      # Pegando apenas os 5 primeiros para o nosso teste inicial
      dados['results'].first(5).each do |filme|
        puts "- #{filme['title']} (#{filme['release_date'][0..3]})"
        puts "  Nota: #{filme['vote_average']}"
        puts "  Sinopse: #{filme['overview'][0..100]}...\n\n"
      end
    else
      puts "⚠️ **Erro na API do TMDB:** #{response.code} - #{response.message}"
    end
  end
end

# Executa o teste
TMDBClient.buscar_em_alta
