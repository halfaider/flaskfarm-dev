## Flaskfarm 디버깅 도커
vscode의 dev 컨테이너 접속 방식을 이용하여 flaskfarm을 디버깅하기 위한 도커.

## 컨테이너의 폴더 구조
```
etc/
  profile.d/
    ff-profile.sh -> /projects/flaskfarm/data/ff-profile.sh
projects/
  .vscode/
    launch.json
    settings.json
  flaskfarm/
    data/
      config.yaml
      ff-profile.sh
      init
      svc
    src/
      flaskfarm/
    pyproject.toml
    requirements.txt
```

- `/projects/flaskfarm/src/flaskfarm`: flaskfarm 저장소를 clone할 경로.
- `/projects/flaskfarm/data/ff-profile.sh`: `/projects/flaskfarm/data/init`, `/projects/flaskfarm/data/svc` 등에서 사용할 환경변수를 설정하는 파일. (심볼릭 링크: `/etc/profile.d/ff-profile.sh`)
- `/projects/flaskfarm/data/config.yaml`: flaskfarm 설정 파일.
- `/projects/flaskfarm/data/init`: s6-overlay 초기화 단계에서 호출됨.
- `/projects/flaskfarm/data/svc`: s6-overlay 서비스 실행 단계에서 호출됨.
- `/projects/.vscode/launch.json`: VSCode 디버깅 설정 파일.
- `/projects/.vscode/settings.json`: VSCode 설정 파일.

## ff-profile.sh

- `FF_REPO`: flaskfarm의 소스 저장소
- `FF_SRC`: flaskfarm의 소스를 저장할 경로
- `FF_REQUIREMENTS_APT_INSTALL`: 컨테이너 시작시 패키치 설치 여부 (true | false)
- `FF_REQUIREMENTS_APT_LIST`: 패키지 설치 목록
- `FF_DEBUG`: `config.yaml`의 `debug` 값이 `false`일 경우 컨테이너 시작시 flaskfarm이 서비스로 실행됩니다. `true`일 경우 flaskfarm이 서비스로 시작되지 않습니다. (기본값: true)

  flaskfarm이 서비스로 실행될 경우 celery도 백그라운드에서 서비스로 시작됩니다. 따라서 `설정>일반설정>비동기 작업>시작시 celery 실행`을 켜지 않아도 돼요.
- 나머지 값은 `config.yaml`에서 설정한 값을 그대로 사용

## 설치

### 이 저장소를 적당한 폴더에 clone 하세요.

```bash
git clone https://github.com/halfaider/flaskfarm-dev
```

### VSCode에서 clone한 폴더를 워크스페이스로 여세요.

예를 들어 `/home/ubuntu/projects/flaskfarm-dev` 경로에 clone이 되었다면 명령어 팔레트에서 `File: Open Folder...`을 선택해 `/home/ubuntu/projects/flaskfarm-dev` 경로를 워크스페이스로 엽니다.

### docker-compose.yaml을 작성하세요.

`docker-compose.sample.yaml`을 참조해서 본인의 `docker-compose.yaml`을 만드세요.
필요하다면 `.env.sample`을 참고하여 `.env`파일도 생성하세요.

컨테이너에서는 `/projects` 폴더를 워크스페이스로 사용합니다.
도커 호스트의 적당한 폴더를 컨테이너의 `/projects` 폴더와 매핑하세요.

### 컨테이너의 워크스페이스 열기

명령어 팔레트에서 `Dev Containers: Reopen in Container..`를 선택합니다. VSCode에서 자동으로 컨테이너를 생성하고 접속합니다.

### 디버깅 실행

Start Debugging(`F5`)으로 Flaskfarm debugger가 실행되는지 확인하세요. 컨테이너 생성 직후에는 초기화 과정이 아직 실행중이라 바로 실행되지 않을 수 있어요.

디버깅 서버가 실행되면 자동으로 9999포트가 forward 됩니다. `http://localhost:9999`로 디버깅 서버에 접속하세요.

### celery 실행

`비동기 작업(celery)`의 celery 실행 명령어는 아래처럼 입력하세요.
```
celery -A flaskfarm.src.flaskfarm.main.celery worker --loglevel=info --pool=gevent --concurrency=2 --config_filepath=flaskfarm/data/config.yaml --running_type=native
```
