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
- `FF_USER_APT_INSTALL`: 컨테이너 시작시 사용자가 추가한 APT 패키지 설치 여부 (true | false)
- `FF_USER_APT_LIST`: 사용자가 추가할 APT 패키지 목록
- `FF_DEBUG`: `config.yaml`의 `debug` 값이 `false`일 경우 컨테이너 시작시 flaskfarm이 서비스로 실행됩니다. `true`일 경우 flaskfarm이 서비스로 시작되지 않습니다. (기본값: true)

  flaskfarm이 서비스로 실행될 경우 celery도 백그라운드에서 서비스로 시작됩니다. 따라서 `설정>일반설정>비동기 작업>시작시 celery 실행`을 켜지 않아도 돼요.
- 나머지 값은 `config.yaml`에서 설정한 값을 그대로 사용

## 설치

### 공통 단계: 저장소 클론 및 워크스페이스 열기
VSCode의 Dev Containers 환경을 사용하기 위해 이 저장소를 로컬에 클론하고 워크스페이스로 열어야 합니다.

1. **저장소 클론**
   ```bash
   git clone https://github.com/halfaider/flaskfarm-dev
   ```
2. **VSCode에서 워크스페이스 열기**
   * VSCode에서 `File: Open Folder...`를 선택해 클론한 `flaskfarm-dev` 폴더를 엽니다.

---

### 방법 1. GitHub Container Registry (GHCR) 이미지 사용 (권장)
별도의 빌드 과정 없이 이미 빌드된 이미지를 다운로드받아 즉시 개발 환경을 구성합니다.

1. **`docker-compose.yaml` 작성**
   * `docker-compose.sample.yaml`을 참조해서 본인의 `docker-compose.yaml`을 생성합니다.
   * 기본적으로 `image: ghcr.io/halfaider/flaskfarm-dev:latest`를 사용하여 이미지를 받아오도록 구성되어 있습니다.
2. **`.env` 작성 (선택)**
   * 필요하다면 `.env.sample`을 참고하여 `.env` 파일을 생성합니다.

---

### 방법 2. 로컬에서 직접 빌드하여 사용
Dockerfile의 내용을 직접 커스터마이징하거나 로컬 환경에서 항상 최신 이미지를 빌드하여 개발 환경을 구성하고자 할 때 사용합니다.

1. **`docker-compose.yaml` 작성 및 빌드 옵션 활성화**
   * `docker-compose.sample.yaml`을 참조해서 본인의 `docker-compose.yaml`을 생성합니다.
   * `image: ghcr.io/...` 설정을 주석 처리하고, 주석 해제하여 로컬 빌드 블록(`build:`)을 활성화합니다.
     ```yaml
     build:
       context: .
       no_cache: true
       network: host
     image: flaskfarm-dev
     ```
2. **`.env` 작성 (선택)**
   * 필요하다면 `.env.sample`을 참고하여 `.env` 파일을 생성합니다.

---

### 컨테이너 접속 및 워크스페이스 열기

1. **VSCode Dev Container 접속**
   * 명령어 팔레트에서 `Dev Containers: Reopen in Container`를 선택합니다. VSCode가 자동으로 이미지 빌드(또는 Pull) 및 컨테이너 접속을 완료합니다.
2. **SSH 직접 접속 (대안)**
   * Dev Container 연결이 어려운 경우 컨테이너의 SSH 서버에 직접 접속합니다. SSH 비밀번호는 `docker-compose.yaml`의 `environment`에서 지정할 수 있습니다.
     ```yaml
     environment:
       PUID: ${YOUR_PUID}
       PGID: ${YOUR_PGID}
       TZ: Asia/Seoul
       SSH_PASSWORD: ${YOUR_SSH_PASSWORD} # 기본값: flaskfarm
     ```

### 디버깅 실행

Start Debugging(`F5`)으로 Flaskfarm debugger가 실행되는지 확인하세요. 컨테이너 생성 직후에는 초기화 과정이 아직 실행중이라 바로 실행되지 않을 수 있어요.

디버깅 서버가 실행되면 자동으로 9999포트가 forward 됩니다. `http://localhost:9999`로 디버깅 서버에 접속하세요.

### celery 실행

`비동기 작업(celery)`의 celery 실행 명령어는 아래처럼 입력하세요.
```
celery -A flaskfarm.src.flaskfarm.main.celery worker --loglevel=info --pool=gevent --concurrency=2 --config_filepath=flaskfarm/data/config.yaml --running_type=native
```
