import panel as pn
import sys
sys.path.insert(1, 'code/')

import prior_dashboard_builder

# Returns a xyz.servable() object
prior_dashboard_builder.dashboard(description=True)

