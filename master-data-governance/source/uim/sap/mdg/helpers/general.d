module uim.sap.mdg.helpers.general;

import uim.sap.mdg;
@safe:

enum string[] MDG_WORKFLOW_STATES = ["draft", "in_review", "approved", "rejected"];

string normalizeWorkflowState(string state) {
    return toLower(state);
}

bool isValidWorkflowState(string state) {
    return MDG_WORKFLOW_STATES.canFind(normalizeWorkflowState(state));
}












