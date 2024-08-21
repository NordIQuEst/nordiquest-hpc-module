# TODO: 
# ## Idea

# - Write the source code in bash and use ["sh-to-mod"](https://modules.readthedocs.io/en/latest/cookbook/source-script-in-modulefile.html) to generate the modules equivalent code and deploy the pushed file
# - Bash script should receive as arguments (or maybe it should create a function that receives these?):

#   - py_script_path: (required string)
#   - python module: (optional string)
#   - requirements_file: (optional string)

# - Bash script should then generate a bash script that will be run by srun
#   - the generated bashcript should:
#     - create the virtual envrionment
#     - load the python module or the deffault
#     - install tergite
#     - install requirements file if exists
#     - run the script
#     - deactivate the environment




# module load cray-python

# python3 -m venv demo-digital-assembly
# source demo-digital-assembly/bin/activate
# pip install tergite

#     module load cray-python

#     python3 -m venv demo-digital-assembly
#     source demo-digital-assembly/bin/activate
#     pip install tergite
#     pip install -r $requirements_txt

#     python run $script_path

#     deactivate

# # Ask for API_TOKEN
# read -s -r -p "Enter a valid QAL9000 API token: " QAL9000_API_TOKEN
# if [ -z "$QAL9000_API_TOKEN" ]; then
#   echo "QAL9000 API token cannot be empty";
#   exit 1;
# fi

# # Clean up
# # Just to be on a slightly safer side, clear the QAL9000_API_TOKEN
# export QAL9000_API_TOKEN=""