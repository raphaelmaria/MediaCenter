import requests

RADARR_API_KEY = "SUA_API_KEY_DO_RADARR"
RADARR_URL = "http://localhost:7878/api/v3" # Altere para o IP e porta do seu Radarr

def get_root_folders():
    headers = {"X-Api-Key": RADARR_API_KEY}
    try:
        response = requests.get(f"{RADARR_URL}/rootfolder", headers=headers)
        response.raise_for_status() # Lança exceção para erros HTTP
        folders = response.json()
        print("Pastas Raiz Disponíveis:")
        for folder in folders:
            print(f"  Caminho: {folder['path']}, ID: {folder['id']}") # O ID da pasta raiz geralmente não é necessário para adicionar filmes, mas o caminho sim.
        return folders
    except requests.exceptions.RequestException as e:
        print(f"Erro ao obter pastas raiz: {e}")
        return None

if __name__ == "__main__":
    root_folders = get_root_folders()
    # Exemplo de como usar o primeiro caminho encontrado
    if root_folders:
        first_folder_path = root_folders[0]['path']
        print(f"\nPrimeiro Caminho de Pasta Raiz encontrado: {first_folder_path}")