import logging
from logging.handlers import RotatingFileHandler # Importa o RotatingFileHandler
import os # Importa o módulo os para manipular caminhos de arquivo

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, CallbackQueryHandler, filters
import requests

# --- Configurações do Bot ---
TELEGRAM_BOT_TOKEN = "[TOKEN COM BOT DO TELEGRAM]" # Substitua pelo seu token do bot do Telegram
RADARR_API_KEY = "[CHAVE API DO RADARR]" # Substitua pela sua chave API do Radarr}"
RADARR_URL = "http://localhost:7878/api/v3" # Altere para o IP ou DDNS e porta do seu Radarr

# IMPORTANTE: Defina estes valores com base nos IDs e caminhos que você obteve do Radarr
QUALITY_PROFILE_ID = [ID DO PROFILE] # Ex: 1 para 1080p, 2 para 4K, etc.
ROOT_FOLDER_PATH = "Folder path do RADARR"

# --- Configurações de Logging ---
LOG_FILE_PATH = "/var/log/radarr-bot/bot.log" # Caminho completo para o arquivo de log
MAX_LOG_SIZE_MB = 300 # Tamanho máximo do arquivo de log em MB
BACKUP_COUNT = 5 # Quantos arquivos de log antigos (rotacionados) manter

# Cria o diretório de log se ele não existir
log_dir = os.path.dirname(LOG_FILE_PATH)
if not os.path.exists(log_dir):
    os.makedirs(log_dir, exist_ok=True) # `exist_ok=True` evita erro se o diretório já existir

# Configuração do logger
# O logger principal do seu script
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO) # Define o nível mínimo de log

# Remove qualquer handler padrão que possa ter sido adicionado por logging.basicConfig()
# Isso garante que apenas os nossos handlers personalizados serão usados.
if logger.hasHandlers():
    logger.handlers.clear()

# Cria um formatador para as mensagens de log
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Configura o RotatingFileHandler
file_handler = RotatingFileHandler(
    LOG_FILE_PATH,
    maxBytes=MAX_LOG_SIZE_MB * 1024 * 1024, # Converte MB para bytes
    backupCount=BACKUP_COUNT
)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

# Opcional: Adicionar um StreamHandler para que os logs também apareçam no console
# Isso é útil para depuração quando você roda o script manualmente
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# Dicionário temporário para armazenar resultados de busca por usuário
user_search_results = {}

# --- Funções de interação com o Radarr ---

def search_radarr_movie(query: str):
    """Pesquisa filmes no Radarr."""
    headers = {"X-Api-Key": RADARR_API_KEY}
    params = {"term": query}
    try:
        response = requests.get(f"{RADARR_URL}/movie/lookup", headers=headers, params=params)
        response.raise_for_status() # Lança exceção para erros HTTP
        logger.info(f"Busca Radarr por '{query}' bem-sucedida.")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Erro ao buscar filme no Radarr para '{query}': {e}")
        return None

def add_radarr_movie(movie_data: dict, quality_profile_id: int, root_folder_path: str): # Removidos os valores padrão daqui
    """Adiciona um filme ao Radarr."""
    headers = {"X-Api-Key": RADARR_API_KEY}
    payload = {
        "title": movie_data["title"],
        "qualityProfileId": quality_profile_id,
        "rootFolderPath": root_folder_path,
        "tmdbId": movie_data["tmdbId"],
        "monitored": True,
        "searchForMovie": True,
        "addOptions": {"searchForMovie": True}
    }
    try:
        response = requests.post(f"{RADARR_URL}/movie", headers=headers, json=payload)
        response.raise_for_status()
        logger.info(f"Filme '{movie_data['title']}' (TMDB ID: {movie_data['tmdbId']}) adicionado ao Radarr com sucesso.")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Erro ao adicionar filme '{movie_data['title']}' (TMDB ID: {movie_data['tmdbId']}) ao Radarr: {e}")
        return None

# --- Funções do Bot do Telegram ---

async def start(update: Update, context):
    """Envia uma mensagem quando o comando /start é emitido."""
    logger.info(f"Comando /start recebido de {update.effective_user.username}")
    await update.message.reply_text("Olá! Eu sou seu bot Radarr. Para pesquisar um filme, basta digitar parte do nome.")

async def search_movie(update: Update, context):
    """Lida com a busca de filmes."""
    query = update.message.text
    logger.info(f"Busca de filme recebida de {update.effective_user.username}: '{query}'")

    if not query:
        await update.message.reply_text("Por favor, digite o nome do filme que deseja pesquisar.")
        return

    movies = search_radarr_movie(query)

    if not movies:
        await update.message.reply_text("Não foi possível buscar o filme no Radarr. Verifique as configurações do bot e do Radarr.")
        logger.warning(f"Nenhum resultado ou erro na busca Radarr para '{query}'.")
        return

    if not movies: # Se a API retornar uma lista vazia ou None (já coberto acima, mas mantido por segurança)
        await update.message.reply_text(f"Nenhum filme encontrado para '{query}'.")
        logger.info(f"Nenhum filme encontrado para '{query}'.")
        return

    chat_id = update.message.chat_id
    user_search_results[chat_id] = movies[:5] # Limita a 5 resultados para não poluir
    logger.info(f"{len(user_search_results[chat_id])} filmes encontrados para '{query}'.")

    keyboard = []
    message_text = "Resultados da busca:\n\n"
    for i, movie in enumerate(user_search_results[chat_id]):
        year = movie.get('year', 'Ano Desconhecido')
        title = movie.get('title', 'Título Desconhecido')
        message_text += f"{i+1}. {title} ({year})\n"
        keyboard.append([InlineKeyboardButton(f"{i+1}. {title} ({year})", callback_data=f"select_movie_{i}")])

    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(message_text + "\nSelecione um filme para adicionar:", reply_markup=reply_markup)

async def button(update: Update, context):
    query_callback = update.callback_query
    await query_callback.answer() # Responde ao callback
    data = query_callback.data
    # Acessa effective_user através do objeto 'update'
    logger.info(f"Botão clicado por {update.effective_user.username}: '{data}'")

    if data.startswith("select_movie_"):
        index = int(data.split("_")[2])
        chat_id = query_callback.message.chat_id

        if chat_id not in user_search_results or len(user_search_results[chat_id]) <= index:
            await query_callback.edit_message_text("Erro: Resultados da busca expiraram ou seleção inválida.")
            logger.error(f"Seleção inválida ou resultados expirados para chat_id {chat_id}, index {index}.")
            return

        selected_movie = user_search_results[chat_id][index]
        movie_title = selected_movie.get('title', 'Filme Desconhecido')
        tmdb_id = selected_movie.get('tmdbId')

        if not tmdb_id:
            await query_callback.edit_message_text(f"Não foi possível adicionar '{movie_title}': TMDB ID não encontrado.")
            logger.error(f"Filme '{movie_title}' sem TMDB ID, não pode ser adicionado.")
            return

        # Passa os IDs de qualidade e pasta raiz configurados nas variáveis globais
        add_success = add_radarr_movie(selected_movie, QUALITY_PROFILE_ID, ROOT_FOLDER_PATH)

        if add_success:
            await query_callback.edit_message_text(f"Filme '{movie_title}' adicionado com sucesso ao Radarr!")
            logger.info(f"Filme '{movie_title}' adicionado via bot.")
        else:
            await query_callback.edit_message_text(f"Erro ao adicionar o filme '{movie_title}' ao Radarr.")
            logger.error(f"Falha ao adicionar o filme '{movie_title}' via bot.")

        # Limpa os resultados da busca para este usuário
        if chat_id in user_search_results:
            del user_search_results[chat_id]

def main():
    """Inicia o bot."""
    logger.info("Iniciando aplicação do bot Radarr...")
    application = Application.builder().token(TELEGRAM_BOT_TOKEN).build()

    # Adiciona os handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, search_movie))
    application.add_handler(CallbackQueryHandler(button))

    # Inicia o polling (o bot ficará escutando por novas mensagens)
    logger.info("Bot Radarr rodando e escutando por mensagens...")
    application.run_polling(allowed_updates=Update.ALL_TYPES)
    logger.info("Aplicação do bot Radarr finalizada.")

if __name__ == "__main__":
    main()