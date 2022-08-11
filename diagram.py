from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.analytics import Dbt
from diagrams.onprem.queue import Kafka


with Diagram("Architecture Diagram", show=False):
    with Cluster("postgres"):
        with Cluster("source tables"):
            source_policies = PostgreSQL("policies")
            source_users = PostgreSQL("users")

    with Cluster("materialize"):
        with Cluster("sources"):
            dbt_raw = Dbt("customer_data_raw")
            dbt_users = Dbt("users")
            dbt_policies = Dbt("policies")

        with Cluster("staging"):
            dbt_user_policies = Dbt("user_policies")

        with Cluster("marts"):
            dbt_usernames_policies = Dbt("usernames_policies")
            dbt_usernames_grouping = Dbt("usernames_grouping")

        with Cluster("sinks"):
            dbt_usernames_policies_snk = Dbt("snk_usernames_policies")
            dbt_usernames_grouping_snk = Dbt("snk_usernames_grouping")

        dbt_raw >> [dbt_users, dbt_policies] >> dbt_user_policies >> [dbt_usernames_policies, dbt_usernames_grouping]
        dbt_usernames_policies >> dbt_usernames_policies_snk
        dbt_usernames_grouping >> dbt_usernames_grouping_snk

    with Cluster("kafka"):
        topic_usernames_policies = Kafka("u08rmoa8-usernames-policies")
        topic_usernames_grouping = Kafka("u08rmoa8-usernames-grouping")

    [source_users, source_policies] >> Edge(label='change data capture', style="dashed", color="firebrick") >> dbt_raw
    dbt_usernames_policies_snk >> Edge(label='notify changes', color="green", style='bold') >> topic_usernames_policies
    dbt_usernames_grouping_snk >> Edge(label='notify changes', color="green", style='bold') >> topic_usernames_grouping
