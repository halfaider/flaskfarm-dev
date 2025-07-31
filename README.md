## Flaskfarm 디버깅 도커
vscode의 dev 컨테이너 접속 방식을 이용하여 flaskfarm을 디버깅하기 위한 도커.

## 컨테이너의 폴더 구조
```
etc/
  profile.d/
    ff-profile.sh -> /flaskfarm-dev/data/ff-profile.sh
flaskfarm-dev/
  .devcontainer/
    devcontainer.json
  .vscode/
    launch.json
    settings.json
  data/
    plugins-dev/
    config.yaml
    ff-profile.sh
    init
    svc
  docker/
    etc/s6-overlay/s6-rc.d/
    tmp/flaskfarm-dev/
  src/flaskfarm/
  .env
  .env.sample
  .gitignore
  docker-compose.sample.yaml
  docker-compose.yaml
  Dockerfile
  pyproject.toml
  README.md
  requirements.txt
```

- `/flaskfarm-dev/flaskfarm`: flaskfarm의 소스 저장 경로.
- `/flaskfarm-dev/data/ff-profile.sh`: `/flaskfarm-dev/data/init`, `/flaskfarm-dev/data/svc` 등에서 사용할 환경변수를 설정하는 파일. (심볼릭 링크: `/etc/profile.d/ff-profile.sh`)
- `/flaskfarm-dev/data/config.yaml`: flaskfarm 설정 파일.
- `/flaskfarm-dev/data/init`: s6-overlay 초기화 단계에서 호출됨.
- `/flaskfarm-dev/data/svc`: s6-overlay 서비스 실행 단계에서 호출됨.
- `/flaskfarm-dev/.vscode/launch.json`: VSCode 디버그 설정 파일.
- `/flaskfarm-dev/.vscode/settings.json`: VSCode 설정 파일.

## ff-profile.sh

- `FF_REPO`: flaskfarm의 소스 저장소
- `FF_SRC`: flaskfarm의 소스를 저장할 경로
- `FF_REQUIREMENTS_APT_INSTALL`: 패키치 설치 여부 (true | false)
- `FF_REQUIREMENTS_APT_LIST`: 패키지 설치 목록
- `FF_DEBUG`: `config.yaml`의 `debug` 값이 `false`일 경우 컨테이너 시작시 flaskfarm이 서비스로 실행된다. `true`일 경우 flaskfarm이 서비스로 시작되지 않는다. (기본값: true)

  flaskfarm이 서비스로 실행될 경우 celery도 백그라운드에서 서비스로 시작된다. 따라서 `설정>일반설정>비동기 작업>시작시 celery 실행`을 켜지 않아도 된다. 하지만 디버깅으로 실행하면 celery는 수동으로 실행해야 한다. 혹은 `비동기 작업` 설정에서 실행.
- 나머지 값은 `config.yaml`에서 설정한 값을 그대로 사용

## 설치

### 이 저장소를 적당한 폴더에 clone 하세요.

```bash
git clone https://github.com/halfaider/flaskfarm-dev
```

### VSCode에서 clone한 폴더를 워크스페이스로 여세요.

예를 들어 `/home/ubuntu/projects/flaskfarm-dev` 경로에 clone이 되었다면 `File > Open Folder...`으로 `/home/ubuntu/projects/flaskfarm-dev` 경로를 워크스페이스로 엽니다.

### docker-compose.yaml을 작성하세요.

`docker-compose.sample.yaml`을 참조해서 본인의 `docker-compose.yaml`을 만드세요.
필요하다면 `.env.sample`을 참고하여 `.env`파일도 생성하세요.

### docker compose로 이미지를 빌드하세요.

```bash
docker compose build --no-cache
```

### docker compose로 컨테이너를 생성하세요.

```bash
docker compose up -d flaskfarm-dev --force-recreate
```

### devcontainer 접속

사전에 VSCode에 `Dev Containers` 확장이 설치되어 있어야 합니다.

컨테이너가 생성되면 `.devcontainer` 폴더가 생성됩니다. 이 `.devcontainer` 폴더의 `devcontainer.json` 설정으로 Dev Container를 실행할 겁니다.

명령어 팔레트(`Ctrl + Shift + P`)로 `Dev Containers: Rebuild Without Cache and Reopen in Container`를 실행하세요.

### 디버깅 실행

Start Debugging(`F5`)으로 Flaskfarm debugger가 실행되는지 확인하세요. 컨테이너 생성 직후에는 초기화 과정이 아직 실행중이라 바로 실행되지 않을 수 있어요.
