import os
import requests

# 환경 변수에서 API 키 가져오기
API_KEY = os.getenv('OPENAI_API_KEY')
FILE_PATH = 'test.txt'  # 수정하려는 파일의 경로

# OpenAI API를 호출하여 파일 수정
def correct_file(file_content):
    response = requests.post(
        'https://api.openai.com/v1/chat/completions',
        headers={
            'Authorization': f'Bearer {API_KEY}',
            'Content-Type': 'application/json',
        },
        json={
            'model': 'gpt-4',
            'messages': [
                {'role': 'system', 'content': 'You are a code optimizer.'},
                {'role': 'user', 'content': f"Optimize the following code to improve its performance and readability:\n\n{file_content}"}
            ],
            'temperature': 0.5,
        },
    )

    response_json = response.json()

    # 오류 처리: API 호출이 실패한 경우
    if 'error' in response_json:
        error_message = response_json['error']['message']
        raise ValueError(f"API 요청 실패: {error_message}")
    
    # 정상적인 응답을 받은 경우
    if 'choices' in response_json:
        return response_json['choices'][0]['message']['content']
    else:
        raise ValueError("Unexpected API response format: 'choices' key not found")

# 메인 로직 실행
try:
    # 파일에서 내용을 읽기
    if os.path.exists(FILE_PATH):
        with open(FILE_PATH, 'r') as file:
            content = file.read()
    else:
        content = ""

    # 파일을 수정
    corrected_content = correct_file(content)

    # 수정된 내용을 파일에 다시 쓰기
    with open(FILE_PATH, 'w') as file:
        file.write(corrected_content)

    print("파일이 성공적으로 수정되었습니다.")

except ValueError as e:
    print(f"오류 발생: {e}")
    exit(1)
