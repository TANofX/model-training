from roboflow import Roboflow
import kdl
import yaml

# read config file
with open('../config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)
name = config["name"].args[0]
model = config["model"].args[0]
imgsz = int(config["imgsz"].args[0])
roboflow_config = config["roboflow"]
api_key = roboflow_config["api-key"].args[0]
workspace = roboflow_config["workspace"].args[0]
project = roboflow_config["project"].args[0]
roboflow_model = roboflow_config["model"].args[0]
version = int(roboflow_config["version"].args[0])

print(f'Download {workspace}/{project}/{version}...')

rf = Roboflow(api_key=api_key)
rf_workspace = rf.workspace(workspace)
rf_project = rf_workspace.project(project)
rf_version = rf_project.version(version)
output_dir = f"../work/datasets/{name}"
rf_version.download(roboflow_model, output_dir)

print(f'downloaded dataset {rf_project.name}/{version} to {output_dir}')

data_yaml_path = f"{output_dir}/data.yaml"
# Generate labels file
with open(data_yaml_path) as f:
    data_yaml = f.read()
data = yaml.safe_load(data_yaml)
labels_file = f"../work/{name}-{imgsz}-{imgsz}-{model}-labels.txt"
with open(labels_file, 'w', encoding='utf-8') as f:
    for name in data['names']:
        f.write(name)
        f.write('\n')
print(f'wrote labels file: {labels_file}')
