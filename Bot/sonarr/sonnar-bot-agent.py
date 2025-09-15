import logging
from logging.handlers import RotatingFileHandler # Importa o RotatingFileHandler
import os # Importa o módulo os para manipular caminhos de arquivo

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, CallbackQueryHandler, filters
import requests

# --- Configurações do Bot ---
TELEGRAM_BOT_TOKEN = "[PEGAR O ID DO BOT NO BOTFATHER]" # Substitua pelo seu token do bot do Telegram]"
SONARR_API_KEY = "API DO SONARR"
SONARR_URL = "http://localhost:8989/api/v3" # Altere para o IP ou DDNS e porta do seu Sonarr

# IMPORTANTE: Defina estes valores com base nos IDs e caminhos que você obteve do Sonarr
SONARR_DEFAULT_QUALITY_PROFILE_ID = 10 # Ex: 1 para HD-720p, 10 para HD-1080p, etc.
SONARR_DEFAULT_ROOT_FOLDER_PATH = "[Folder Path]]" # Ex: "/mnt/data/series"

# --- Configurações de Logging ---
LOG_FILE_PATH = "/var/log/sonarr-bot/bot.log" # Caminho completo para o arquivo de log
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
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# Dicionário temporário para armazenar resultados de busca por usuário
user_search_results = {}

# --- Funções de interação com o Sonarr ---

def search_sonarr_series(query: str):
    """Pesquisa séries no Sonarr."""
    headers = {"X-Api-Key": SONARR_API_KEY}
    params = {"term": query}
    try:
        response = requests.get(f"{SONARR_URL}/series/lookup", headers=headers, params=params)
        response.raise_for_status()
        logger.info(f"Busca Sonarr por '{query}' bem-sucedida.")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Erro ao buscar série no Sonarr para '{query}': {e}")
        return None

def add_sonarr_series(series_data: dict, quality_profile_id: int, root_folder_path: str):
    """Adiciona uma série ao Sonarr."""
    headers = {"X-Api-Key": SONARR_API_KEY}
    payload = {
        "title": series_data.get("title"),
        "tvdbId": series_data.get("tvdbId"),
        "qualityProfileId": quality_profile_id,
        "rootFolderPath": root_folder_path,
        "seasonFolder": True,
        "monitored": True,
        "addOptions": {
            "monitor": "all",
            "searchForMissingEpisodes": True
        }
    }
    try:
        response = requests.post(f"{SONARR_URL}/series", headers=headers, json=payload)
        response.raise_for_status()
        logger.info(f"Série '{series_data.get('title')}' (TVDB ID: {series_data.get('tvdbId')}) adicionada ao Sonarr com sucesso.")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Erro ao adicionar série '{series_data.get('title')}' (TVDB ID: {series_data.get('tvdbId')}) ao Sonarr: {e}")
        return None

# --- Funções do Bot do Telegram ---

async def start(update: Update, context):
    """Envia uma mensagem quando o comando /start é emitido."""
    logger.info(f"Comando /start recebido de {update.effective_user.username}")
    await update.message.reply_text("Olá! Eu sou seu bot Sonarr. Para pesquisar uma série, basta digitar parte do nome.")

async def search_series(update: Update, context):
    """Lida com a busca de séries."""
    query = update.message.text
    logger.info(f"Busca de série recebida de {update.effective_user.username}: '{query}'")

    if not query:
        await update.message.reply_text("Por favor, digite o nome da série que deseja pesquisar.")
        return

    series_list = search_sonarr_series(query)

    if not series_list:
        await update.message.reply_text("Não foi possível buscar a série no Sonarr. Verifique as configurações do bot e do Sonarr.")
        logger.warning(f"Nenhum resultado ou erro na busca Sonarr para '{query}'.")
        return

    if not series_list: # Se a API retornar uma lista vazia ou None
        await update.message.reply_text(f"Nenhuma série encontrada para '{query}'.")
        logger.info(f"Nenhuma série encontrada para '{query}'.")
        return

    chat_id = update.message.chat_id
    user_search_results[chat_id] = series_list[:5] # Limita a 5 resultados
    logger.info(f"{len(user_search_results[chat_id])} séries encontradas para '{query}'.")

    keyboard = []
    message_text = "Resultados da busca:\n\n"
    for i, series in enumerate(user_search_results[chat_id]):
        year = series.get('year', 'Ano Desconhecido')
        title = series.get('title', 'Título Desconhecido')
        message_text += f"{i+1}. {title} ({year})\n"
        keyboard.append([InlineKeyboardButton(f"{i+1}. {title} ({year})", callback_data=f"select_series_{i}")])

    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(message_text + "\nSelecione uma série para adicionar:", reply_markup=reply_markup)

async def button(update: Update, context):
    """Lida com cliques em botões inline."""
    query_callback = update.callback_query
    await query_callback.answer() # Responde ao callback

    data = query_callback.data
    logger.info(f"Botão clicado por {update.effective_user.username}: '{data}'")

    if data.startswith("select_series_"):
        index = int(data.split("_")[2])
        chat_id = query_callback.message.chat_id

        if chat_id not in user_search_results or len(user_search_results[chat_id]) <= index:
            await query_callback.edit_message_text("Erro: Resultados da busca expiraram ou seleção inválida.")
            logger.error(f"Seleção inválida ou resultados expirados para chat_id {chat_id}, index {index}.")
            return

        selected_series = user_search_results[chat_id][index]
        series_title = selected_series.get('title', 'Série Desconhecida')
        tvdb_id = selected_series.get('tvdbId')

        if not tvdb_id:
            await query_callback.edit_message_text(f"Não foi possível adicionar '{series_title}': TVDB ID não encontrado.")
            logger.error(f"Série '{series_title}' sem TVDB ID, não pode ser adicionada.")
            return

        # Passa os IDs de qualidade e pasta raiz configurados nas variáveis globais
        add_success = add_sonarr_series(selected_series, SONARR_DEFAULT_QUALITY_PROFILE_ID, SONARR_DEFAULT_ROOT_FOLDER_PATH)

        if add_success:
            await query_callback.edit_message_text(f"Série '{series_title}' adicionada com sucesso ao Sonarr!")
            logger.info(f"Série '{series_title}' adicionada via bot.")
        else:
            await query_callback.edit_message_text(f"Erro ao adicionar a série '{series_title}' ao Sonarr.")
            logger.error(f"Falha ao adicionar a série '{series_title}' via bot.")

        # Limpa os resultados da busca para este usuário
        if chat_id in user_search_results:
            del user_search_results[chat_id]

def main():
    """Inicia o bot."""
    logger.info("Iniciando aplicação do bot Sonarr...")
    application = Application.builder().token(TELEGRAM_BOT_TOKEN).build()

    # Adiciona os handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, search_series))
    application.add_handler(CallbackQueryHandler(button))

    # Inicia o polling
    logger.info("Bot Sonarr rodando e escutando por mensagens...")
    application.run_polling(allowed_updates=Update.ALL_TYPES)
    logger.info("Aplicação do bot Sonarr finalizada.")

if __name__ == "__main__":
    main()