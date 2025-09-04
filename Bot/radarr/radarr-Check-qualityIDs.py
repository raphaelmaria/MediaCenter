import requests

RADARR_API_KEY = "SUA_API_KEY_DO_RADARR"
RADARR_URL = "http://localhost:7878/api/v3" # Altere para o IP e porta do seu Radarr

def get_quality_profiles():
    headers = {"X-Api-Key": RADARR_API_KEY}
    try:
        response = requests.get(f"{RADARR_URL}/qualityprofile", headers=headers)
        response.raise_for_status() # Lança exceção para erros HTTP
        profiles = response.json()
        print("Perfis de Qualidade Disponíveis:")
        for profile in profiles:
            print(f"  Nome: {profile['name']}, ID: {profile['id']}")
        return profiles
    except requests.exceptions.RequestException as e:
        print(f"Erro ao obter perfis de qualidade: {e}")
        return None

if __name__ == "__main__":
    quality_profiles = get_quality_profiles()
    # Exemplo de como usar o primeiro ID encontrado
    if quality_profiles:
        first_profile_id = quality_profiles[0]['id']
        print(f"\nPrimeiro ID de Perfil de Qualidade encontrado: {first_profile_id}")