# Curador de Cinema AI 🎬

Um sistema inteligente de curadoria cinematográfica desenvolvido em **Ruby**. O projeto extrai o histórico pessoal do usuário no Filmow via Web Scraping, cruza com a base global do TMDB e utiliza a **Gemini 2.5 Flash API** para sugerir obras inéditas e tecnicamente relevantes, fugindo do óbvio dos algoritmos de streaming.

## 🚀 Funcionalidades

- **Web Scraping Resiliente**: Extração de +2.300 filmes e notas do perfil Filmow utilizando `Nokogiri`.
- **Inteligência de Filtragem**: Algoritmo de interseção que remove filmes já assistidos da lista de candidatos.
- **Integração com TMDB**: Busca avançada por gênero, filtrando produções pós-1960 e com alta relevância técnica.
- **Cérebro de Curadoria (AI)**: Prompt Engineering aplicado ao Gemini 2.5 Flash para recomendações focadas em "Deep Cuts" e cinema de autor.
- **Interface CLI**: Menu interativo no terminal para escolha de 15 diferentes gêneros.

## 🛠️ Tech Stack

- **Linguagem:** Ruby
- **Extração de Dados:** Nokogiri
- **APIs:** TMDB API (Discovery) & Google Gemini 1.5/2.5 Flash
- **Persistência:** CSV (Histórico de visualização)

## 📦 Como Instalar

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/Peuvictor/curador-cinema-ai.git](https://github.com/Peuvictor/curador-cinema-ai.git)
   cd curador-cinema-ai

Instale as dependências:

Bash
bundle install


3. **Configure as variáveis de ambiente:**
   Exporte suas chaves de API no terminal (ou utilize um gerenciador de envs):
   ```bash
   export TMDB_ACCESS_TOKEN="seu_token_aqui"
   export GEMINI_API_KEY="sua_chave_aqui"

🎮 Como Usar
Atualize seu histórico:
No arquivo filmow_scraper.rb, insira seu usuário e rode:

Bash
ruby filmow_scraper.rb


2. **Receba sua curadoria:**
   Execute o orquestrador e escolha seu gênero favorito no menu:
   ```bash
   ruby curador_brain.rb
