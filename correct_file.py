import os
import requests

API_KEY = os.getenv('OPENAI_API_KEY')
FILE_PATH = 'test.txt'  # 정확한 파일 경로로 수정

def correct_file(file_content):
    response = requests.post(
        'https://api.openai.com/v1/chat/completions',
        headers={
            'Authorization': f'Bearer {API_KEY}',
            'Content-Type': 'application/json',
        },
        json={
            'model': 'gpt-3.5-turbo',
            'messages': [
                {'role': 'system', 'content': 'You are a code fixer bot.'},
                {'role': 'user', 'content': f'Correct the following code:\n\n{file_content}'}
            ],
            'temperature': 0.7,
        },
    )
    
    # 응답을 출력하여 확인
    print("API 응답:", response.json())

    # 응답이 예상된 형태인지 확인하고 처리
    if 'choices' in response.json():
        return response.json()['choices'][0]['message']['content']
    else:
        raise ValueError("Unexpected API response format: 'choices' key not found")

with open(FILE_PATH, 'r') as file:
    content = file.read()

corrected_content = correct_file(content)

with open(FILE_PATH, 'w') as file:
    file.write(corrected_content)
