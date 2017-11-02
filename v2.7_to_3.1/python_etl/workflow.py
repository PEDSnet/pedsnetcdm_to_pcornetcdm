import yaml
import logging
from demographicsETL import demographic_etl


def set_up_logger():
    """Sets up the logger format and location."""

    logger.setLevel(logging.DEBUG)
    logger.propagate = 0

    file_handler = logging.FileHandler('workflow_process.log')
    file_handler.setLevel(logging.DEBUG)

    log_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

    file_handler.setFormatter(log_formatter)
    logger.addHandler(file_handler)


def get_config():
    try:
        with open('p_to_p.yml', 'r') as f:
            config = yaml.load(f)
            return config
    except:
        logger.exception("Exception")
        return None


if __name__ == "__main__":
    # get connect and table details
    # suppress all errors but log them
    logger = logging.getLogger(__name__)
    set_up_logger()

    # get connection details
    config = get_config()
    if config is None:
        print("Unable to process configuration file p_to_p.yml")
        exit(1)

    # perform etl for the tables
    # so far only demographics
    demographic_etl.delay(config)


