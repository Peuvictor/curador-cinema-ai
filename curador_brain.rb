require 'csv'
require 'json'
require 'net/http'
require 'uri'
require_relative 'tmdb_client'

class CuradorBrain
  GEMINI_KEY = ENV['GEMINI_API_KEY']

  GENRES = {
    "1"  => { nome: "Suspense/Thriller", id: 53 },
    "2"  => { nome: "Comédia", id: 35 },
    "3"  => { nome: "Máfia & Crime", id: 80 },
    "4"  => { nome: "Ficção Científica", id: 878 },
    "5"  => { nome: "Documentário", id: 99 },
    "6"  => { nome: "Terror/Horror", id: 27 },
    "7"  => { nome: "Drama", id: 18 },
    "8"  => { nome: "Ação", id: 28 },
    "9"  => { nome: "Faroeste (Western)", id: 37 },
    "10" => { nome: "Animação", id: 16 },
    "11" => { nome: "Guerra", id: 10752 },
    "12" => { nome: "História", id: 36 },
    "13" => { nome: "Mistério", id: 9648 },
    "14" => { nome: "Fantasia", id: 14 },
    "15" => { nome: "Neo-Noir", id: 80 } # Mapeado para Crime com filtro de estilo no prompt
  }

  def self.menu
    puts "\n🎬 --- CURADOR CINEMATOGRÁFICO ELITE (v3.0) ---"
    puts "Filtro: Pós-1960 | Foco: Deep Cuts & Técnica"

    GENRES.each_slice(2) do |left, right|
      l = "#{left[0].ljust(2)} - #{left[1][:nome].ljust(20)}"
      r = right ? "#{right[0].ljust(2)} - #{right[1][:nome]}" : ""
      puts "#{l} | #{r}"
    end

    print "\nQual a sua obsessão de hoje? "
    escolha = gets.chomp
    return puts "❌ Opção inválida." unless GENRES.key?(escolha)

    rodar(GENRES[escolha])
  end

  def self.rodar(genero_alvo)
    puts "\n🧠 **Analisando base de dados para: #{genero_alvo[:nome]}...**"

    historico = []
    CSV.foreach("historico_filmow.csv", headers: true) { |row| historico << row['Titulo']&.downcase }

    # Busca 4 páginas de resultados para garantir variedade (80 filmes)
    candidatos = buscar_por_genero(genero_alvo[:id])

    # Filtro de Intersecção
    novidades = candidatos.reject { |f| historico.include?(f[:titulo].downcase) }

    if novidades.size < 4
      puts "🏁 Nenhuma 'pérola' inédita encontrada neste gênero hoje."
      return
    end

    veredito = consultar_ia(novidades, genero_alvo[:nome])

    puts "\n--- ✨ AS 4 ESCOLHAS DO CURADOR ---"
    puts veredito
    puts "-----------------------------------"
  end

  private

  def self.buscar_por_genero(id)
    filmes = []
    (1..4).each do |p|
      # Filtros: Desde 1960, min 150 votos, ordenado por relevância técnica (vote_average)
      url = URI("https://api.themoviedb.org/3/discover/movie?with_genres=#{id}&primary_release_date.gte=1960-01-01&vote_count.gte=150&sort_by=vote_average.desc&language=pt-BR&page=#{p}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Bearer #{TMDBClient::TOKEN}"

      response = http.request(request)
      dados = JSON.parse(response.read_body)

      dados['results'].each do |f|
        filmes << { titulo: f['title'], sinopse: f['overview'], ano: f['release_date']&.split('-')&.first, nota: f['vote_average'] }
      end
    end
    filmes
  end

  def self.consultar_ia(lista, genero)
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{GEMINI_KEY}")

    prompt = <<~PROMPT
      Você é um crítico de cinema especializado em clássicos e cinema de autor.
      O usuário assistiu +2300 filmes e possui acesso a Netflix, Max, Prime Video, Disney+ e fontes alternativas.

      TAREFA:
      Escolha os **4 FILMES MAIS IMPACTANTES** tecnicamente da lista de #{genero} abaixo.
      FUJA do óbvio (nada de blockbusters saturados). Foque em diretores renomados, fotografia marcante ou roteiros geniais.

      FORMATO DE SAÍDA:
      - **TÍTULO (ANO)**
      - **O Diferencial**: Por que um cinéfilo sério precisa ver este filme? (Seja direto e mordaz).
      - **Onde encontrar**: Indique se é provável estar no [Streaming] ou se é um 'Hidden Gem' de fontes externas.
      - **Expectativa Técnica**: 0-100%.

      LISTA DE CANDIDATOS:
      #{lista.map { |f| "#{f[:titulo]} (#{f[:ano]}) - Nota TMDB: #{f[:nota]} - Sinopse: #{f[:sinopse]}" }.join("\n")}
    PROMPT

    res = Net::HTTP.post(uri, { contents: [{ parts: [{ text: prompt }] }] }.to_json, { 'Content-Type' => 'application/json' })
    JSON.parse(res.body).dig('candidates', 0, 'content', 'parts', 0, 'text') || "Erro na IA."
  end
end

CuradorBrain.menu
