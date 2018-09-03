# coding=utf-8
import os
import shutil

import yaml
from jinja2 import Template


def deployment_root(*path):
    root = os.path.join(os.path.dirname(__file__), '../../../')
    root = os.path.abspath(root)
    return os.path.join(root, *path)


def read_mount_list(definition, service_name):
    paths = definition['services'][service_name]['volumes']
    paths = [p for p in paths if p.startswith('../src/kobo-docker')]
    return paths


def copy_file_list(mount_list, service_name):
    production_build_root = deployment_root('production/docker')
    files_root = os.path.join(production_build_root, service_name, 'files')
    copy_list = []

    try:
        os.makedirs(files_root)
    except:
        pass

    for p in mount_list:
        parsed_paths = p.split(':')
        source = parsed_paths[0]
        source_path = deployment_root(source)
        basename = os.path.basename(source_path)
        target_path = os.path.join(files_root, basename)
        container_path = parsed_paths[1]
        if os.path.isfile(source_path):
            shutil.copy(source_path, target_path)
        elif os.path.isdir(source_path):
            if not basename:
                basename = os.path.basename(os.path.dirname(source_path))
            target_path = os.path.join(files_root, basename)
            print basename
            print source_path
            print files_root
            shutil.copytree(source_path, target_path)
            if not container_path.endswith('/'):
                container_path = container_path + '/'

        service_path = os.path.join(production_build_root, service_name)

        copy_list.append({
            'source': os.path.relpath(target_path, service_path),
            'target': container_path
        })
    return copy_list


def generate_docker_copy_instruction(base_image, copy_list):
    dockerfile_template_path = deployment_root(
        'production/docker/utils/Dockerfile.j2')
    with open(dockerfile_template_path) as f:
        template = Template(f.read())

    contexts = {
        'BASE_IMAGE': base_image,
        'FILES': copy_list
    }
    return template.render(**contexts)


def generate_dockerfile_for_service(
        service_name,
        base_image_name):

    dockerfile_path = deployment_root(
        'production/docker', service_name, 'Dockerfile')

    # cleanup
    dirname = os.path.dirname(dockerfile_path)
    try:
        os.remove(dockerfile_path)
    except:
        pass

    try:
        shutil.rmtree(os.path.join(
            dirname, 'files'))
    except:
        pass

    with open(deployment_root('docker-compose.volume-definition.yml')) as f:
        volume_definition = yaml.load(f)

    mount_list = read_mount_list(volume_definition, service_name)
    copy_list = copy_file_list(mount_list, service_name)
    dockerfile_content = generate_docker_copy_instruction(
        base_image_name, copy_list)

    with open(dockerfile_path, 'w') as f:
        f.write(dockerfile_content)


def parse_env_txt(filepath):
    with open(filepath) as f:
        lines = []
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                lines.append(line)

    return lines


def generate_yaml_env_list(filepath):
    lines = parse_env_txt(filepath)
    return [
        ' - ' + l for l in lines
    ]


def print_env_list(filepath):
    lines = generate_yaml_env_list(filepath)
    for l in lines:
        print l
