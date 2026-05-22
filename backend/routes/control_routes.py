from flask import Blueprint, jsonify

bp = Blueprint("control", __name__)

# ================= ETAT EXTRACTION =================
extraction_status = False


# ================= START EXTRACTION =================
@bp.route("/start", methods=["POST"])
def start_extraction():

    global extraction_status

    extraction_status = True

    return jsonify({
        "message": "Extraction started",
        "status": extraction_status
    }), 200


# ================= STOP EXTRACTION =================
@bp.route("/stop", methods=["POST"])
def stop_extraction():

    global extraction_status

    extraction_status = False

    return jsonify({
        "message": "Extraction stopped",
        "status": extraction_status
    }), 200


# ================= GET STATUS =================
@bp.route("/status", methods=["GET"])
def get_status():

    return jsonify({
        "status": extraction_status
    }), 200