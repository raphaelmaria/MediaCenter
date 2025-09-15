import requests

# --- Configurações do Sonarr ---
# SUBSTITUA PELOS SEUS VALORES REAIS
SONARR_API_KEY = "API SONARR"
SONARR_URL = "http://localhost:8989/api/v3" # Altere para o IP e porta do seu Sonarr

def get_sonarr_quality_profiles():
    """Obtém e exibe os perfis de qualidade do Sonarr."""
    headers = {"X-Api-Key": SONARR_API_KEY}
    try:
        response = requests.get(f"{SONARR_URL}/qualityprofile", headers=headers)
        response.raise_for_status()
        profiles = response.json()
        print("Perfis de Qualidade do Sonarr Disponíveis:")
        for profile in profiles:
            print(f"  Nome: {profile['name']}, ID: {profile['id']}")
        return profiles
    except requests.exceptions.RequestException as e:
        print(f"Erro ao obter perfis de qualidade do Sonarr: {e}")
        return None

def get_sonarr_root_folders():
    """Obtém e exibe as pastas raiz do Sonarr."""
    headers = {"X-Api-Key": SONARR_API_KEY}
    try:
        response = requests.get(f"{SONARR_URL}/rootfolder", headers=headers)
        response.raise_for_status()
        folders = response.json()
        print("Pastas Raiz do Sonarr Disponíveis:")
        for folder in folders:
            # Para Sonarr, o 'path' é o que nos interessa principalmente ao adicionar uma série
            print(f"  Caminho: {folder['path']}")
        return folders
    except requests.exceptions.RequestException as e:
        print(f"Erro ao obter pastas raiz do Sonarr: {e}")
        return None

if __name__ == "__main__":
    print("--- Buscando configurações do Sonarr ---")
    quality_profiles = get_sonarr_quality_profiles()
    print("\n")
    root_folders = get_sonarr_root_folders()

    if quality_profiles and root_folders:
        print("\n--- Exemplo de uso dos dados ---")
        # Você pode escolher o primeiro profile/folder ou um específico.
        # Anote os valores que você deseja usar no bot do Telegram.
        if quality_profiles:
            print(f"Sugestão de Quality Profile ID: {quality_profiles[0]['id']} (Nome: {quality_profiles[0]['name']})")
        if root_folders:
            print(f"Sugestão de Root Folder Path: {root_folders[0]['path']}")
    else:
        print("\nNão foi possível obter todas as configurações do Sonarr. Verifique sua API Key e URL.")