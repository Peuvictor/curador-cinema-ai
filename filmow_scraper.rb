require 'nokogiri'
require 'open-uri'
require 'csv'

class FilmowScraper
  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language" => "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7"
  }

  def self.extrair(usuario)
    filmes = []
    pagina = 1

    puts "🚀 Iniciando extração pesada do perfil: #{usuario}..."

    loop do
      url = "https://filmow.com/usuario/#{usuario}/filmes/ja-vi/?pagina=#{pagina}"

      begin
        html = URI.open(url, **HEADERS).read
        doc = Nokogiri::HTML(html, nil, 'UTF-8')

        # Miramos no card (li) para pegar o conjunto Título + Nota
        itens_pagina = doc.css('#movies-list li')

        break if itens_pagina.empty?

        itens_pagina.each do |item|
          link_tag = item.css('a[title]').first
          next unless link_tag

          titulo_bruto = link_tag['title']

          # --- Lógica de Extração de Ano Resiliente ---
          if titulo_bruto.match(/(.+?)\s*\((\d{4})\)$/)
            titulo = $1.strip
            ano = $2
          else
            # Fallback: Se não achar o padrão "(9999)", tenta apenas extrair 4 dígitos
            titulo = titulo_bruto.gsub(/\(\d{4}\)$/, "").strip
            ano = titulo_bruto.scan(/\d{4}/).last || "N/A"
          end

          # --- Lógica de Captura de Nota ---
          nota_tag = item.css('.my-rating').first || item.css('[title*="Nota:"]').first
          if nota_tag && nota_tag['title']
            nota = nota_tag['title'].gsub(/[^\d.,]/, '')
          else
            nota = "N/A"
          end

          filmes << { titulo: titulo, ano: ano, nota: nota }
        end

        puts "✅ Página #{pagina} processada com sucesso... (#{filmes.size} filmes acumulados)"
        pagina += 1

        # Delay humano variável para evitar o erro 429
        sleep(rand(1.8..3.5))

      rescue OpenURI::HTTPError => e
        if e.message.include?('429')
          puts "⏳ Bloqueio temporário (429). Aguardando 40 segundos para o servidor respirar..."
          sleep(40)
          retry
        else
          puts "🛑 Fim da leitura. Motivo: #{e.message}"
          break
        end
      rescue StandardError => e
        puts "⚠️ Erro inesperado na página #{pagina}: #{e.message}"
        break
      end
    end

    salvar_csv(filmes)
  end

  def self.salvar_csv(filmes)
    # Remove duplicatas baseadas no título para garantir limpeza
    filmes.uniq! { |f| f[:titulo].downcase }

    CSV.open("historico_filmow.csv", "w", write_headers: true, headers: ["Titulo", "Ano", "Minha Nota"]) do |csv|
      filmes.each { |f| csv << [f[:titulo], f[:ano], f[:nota]] }
    end

    puts "\n🏁 Missão cumprida! #{filmes.size} filmes catalogados em 'historico_filmow.csv'."
  end
end

# === EXECUÇÃO ===
MEU_USUARIO_FILMOW = "pedrovictorguimaraes73"
FilmowScraper.extrair(MEU_USUARIO_FILMOW)
