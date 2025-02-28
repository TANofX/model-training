from roboflow import Roboflow
import kdl
import yaml

# read config file
with open('../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)["roboflow"]
api_key = config["api-key"].args[0]
workspace = config["workspace"].args[0]
project = config["project"].args[0]
version = int(config["version"].args[0])

print(f'Download {workspace}/{project}/{version}...')

rf = Roboflow(api_key=api_key)
rf_workspace = rf.workspace(workspace)
rf_project = rf_workspace.project(project)
rf_version = rf_project.version(version)
output_dir = '../work/dataset'
rf_version.download("yolov8", output_dir)

print(f'downloaded dataset {rf_project.name}/{version} to {output_dir}')

# Generate labels file
with open('../work/dataset/data.yaml') as f:
    dataYaml = f.read()
data = yaml.safe_load(dataYaml)
labels_file = '../work/best-640-640-yolov8n-labels.txt'
with open(labels_file, 'w', encoding='utf-8') as f:
    for name in data['names']:
        f.write(name)
        f.write('\n')
print(f'wrote labels file: {labels_file}')
