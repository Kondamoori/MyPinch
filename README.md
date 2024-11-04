# MyPinch - List of games from IGDB and its details.
Sample app loads data from IGDB and load its details with screenshots and description.

# Application Functionality
- Loading list of games form IGDB servers and displaying them on grid view with pagination support.
- Each game display it cover photo and its name on overview screen.
- Offline support for data when connect to backend is failed.
- Deatils of game with game cover phtoto and its summary.
- Deatails screen also contain list of game screenshots which will use /screenshots api of IGDB.
- App supports offline image cache which will load image from disk cache if exists.
- If cover image service fails, you see a place holder image which is on app launching screen.

# Technical Design
- Used Xcode 16 & SwiftUI, Swift.
- No third party libraries are used.
- Used MVVM-C pattern (combination of the Model-View-ViewModel architecture, plus the Coordinator pattern), swift async-await for network request.
- Core data to support offline store.
- XCTest for unit testing viewModels for business logic (fetchign, saving, loading) of data.

# Highlevel overview of app flow.
![Architecture drawio](https://github.com/user-attachments/assets/c0238520-db6f-4506-be8f-196e21307efe)

# Test Coverage
- App has unit test coverage with 75 %.
- ![image](https://github.com/user-attachments/assets/9cf9310d-60df-4bd1-ae1e-7494c782948f)

# Improvements can be considered if we have some more time.
- Accessibility
- UITests to have more coverage of happy flows.
- Improve image downloader to cancel image downloading when the cell away form the visibility, rightnow it's only stop duplicate requests if request for same url is already in process.
- Stop firing too many requests to IGDB with pagination, we need to stop user at list level while scrolling afer few scrools.
- Improve the list with search.
- Cache clearing mechanisam.
- May be design change, first look only offline data and sync with backend with background task.
- Core data version management.

# Screenshots & Quick movie of app look.

List screen
![Simulator Screenshot - iPhone 15 Pro - 2024-11-04 at 01 36 35](https://github.com/user-attachments/assets/96e86f26-b2c1-4baf-a94a-bdf5e10838e7)

Details screen
![Simulator Screenshot - iPhone 15 Pro - 2024-11-04 at 01 36 53](https://github.com/user-attachments/assets/dd5ff5a8-6bd3-496a-866f-e3a7c92e3788)

Error screen
![Simulator Screenshot - iPhone 15 Pro - 2024-11-04 at 01 44 37](https://github.com/user-attachments/assets/3fa9cbf6-4983-4442-a738-ba948ab5847d)
![Simulator Screenshot - iPhone 15 Pro - 2024-11-04 at 01 44 25](https://github.com/user-attachments/assets/9af82c3b-d3e8-43cf-81f6-c2421bdef3af)

Video

https://github.com/user-attachments/assets/ca24c6ad-b085-414a-b71d-4343eaca1a1e

