import logging
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_logging = LoggingIntegration(
    level=logging.INFO,
    event_level=logging.ERROR
)

sentry_sdk.init(
    "https://8086d7ea9f1748eaa84b24dcb7f92e67@o1070713.ingest.sentry.io/6066971",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
    
)

a=int(input("Введите значение переменной a ="))
b=str(input("Введите значение переменной b ="))
print("Сумма a и b =", a+b)

