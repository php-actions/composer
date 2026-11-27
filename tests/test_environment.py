"""Exercise the environment argument builder without running Docker or Composer."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class EnvironmentTest(unittest.TestCase):
    def test_preserves_values_and_filters_names(self):
        source = (Path(__file__).resolve().parents[1] / 'composer-action.bash').read_text()
        block = source[source.index('dockerKeys=()'):source.index('if [ -n "$ACTION_CONTAINER_WORKDIR"')]
        environment = {
            'PATH': os.environ['PATH'],
            'MULTILINE_CONFIG': 'first line\nCOMPOSER_AUTH=replacement\nprivate continuation text',
            'BLACKSMITH_STORE_STATS': 'System Statistics:\nAvailable CPUs: 10',
            'EMPTY_VALUE': '',
            'PUNCTUATION': 'a=b "quoted" \\ backslash',
            'IMAGE_DEFAULT': 'host override',
            'INVALID-NAME': 'private invalid value',
        }
        script = '''docker() {
    printf 'IMAGE_DEFAULT=image value\\0IMAGE_MULTILINE=first\\nFAKE_KEY=continuation\\0'
}
docker_tag=test
''' + block + '''
python3 -c 'import json, os, sys; print(json.dumps({"args": sys.argv[1:], "values": {key: os.environ[key] for key in sys.argv[2::2]}}))' "${dockerEnvArgs[@]}"
'''
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(['bash', '-e', '-c', script], env=environment,
                                    cwd=directory, text=True, capture_output=True, check=True)
            log = (Path(directory) / 'output.log').read_text()
        output = json.loads(result.stdout)
        args = output['args']
        self.assertTrue(all(arg == '--env' for arg in args[::2]))
        names = args[1::2]
        for key in ('MULTILINE_CONFIG', 'BLACKSMITH_STORE_STATS', 'EMPTY_VALUE', 'PUNCTUATION'):
            self.assertIn(key, names)
            self.assertEqual(output['values'][key], environment[key])
        for key in ('COMPOSER_AUTH', 'IMAGE_DEFAULT', 'INVALID-NAME'):
            self.assertNotIn(key, names)
        self.assertNotIn('private', log)
        self.assertNotIn('replacement', log)
        self.assertNotIn('Available CPUs', log)


if __name__ == '__main__':
    unittest.main()
