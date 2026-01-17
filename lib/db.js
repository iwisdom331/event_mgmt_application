const { MongoClient } = require('mongodb');

// Your connection string (Replace <password> with your actual password)
const uri = "mongodb+srv://iwisdom331:Ar3oTR96F09azFQn@profile-pictures.1p0qslg.mongodb.net/?retryWrites=true&w=majority&appName=profile-pictures";

async function connectDB() {
    try {
        const client = new MongoClient(uri);
        await client.connect();
        console.log("Connected to MongoDB!");
        client.close(); // Close connection after testing
    } catch (error) {
        console.error("Error connecting to MongoDB:", error);
    }
}

// Call the function
connectDB();
