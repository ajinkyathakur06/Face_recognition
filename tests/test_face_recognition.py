import pytest
import cv2
import numpy as np
import attendence_sys.recognizer as recognizer
import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Mock VideoCapture to avoid webcam access
class MockVideoCapture:
    def __init__(self, *args, **kwargs):
        self.frames = 0

    def read(self):
        self.frames += 1
        if self.frames > 1:
            return False, None
        dummy_frame = np.zeros((480, 640, 3), dtype=np.uint8)
        return True, dummy_frame

    def release(self):
        pass

def mock_imshow(name, frame):
    return

@pytest.fixture
def test_image(tmp_path):
    # Create a folder structure
    branch_dir = tmp_path / "CSE" / "2025" / "A"
    branch_dir.mkdir(parents=True)

    # Copy real test image from repo
    real_img_path = os.path.join(os.path.dirname(__file__), "data", "test_face.jpg")
    test_image_path = branch_dir / "test_face.jpg"
    cv2.imwrite(str(test_image_path), cv2.imread(real_img_path))

    return {
        "branch": "CSE",
        "year": "2025",
        "section": "A",
        "base_path": tmp_path
    }

def test_recognizer_with_real_image(monkeypatch, test_image):
    monkeypatch.setattr(cv2, "VideoCapture", MockVideoCapture)
    monkeypatch.setattr(cv2, "imshow", mock_imshow)

    # Patch __file__ reference inside recognizer if it relies on its directory
    monkeypatch.setattr("attendence_sys.recognizer.__file__", os.path.join(test_image["base_path"], "dummy.py"))

    details = {
        "branch": test_image["branch"],
        "year": test_image["year"],
        "section": test_image["section"]
    }

    recognized_names = recognizer.Recognizer(details)
    assert isinstance(recognized_names, list)
