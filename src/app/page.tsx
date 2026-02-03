export default function Home() {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      <div className="p-8">
        <h1 className="text-3xl font-bold mb-4">OpenClaw Admin Panel</h1>
        <p className="text-[#6b7280] mb-8">
          Granular permission management for AI agents
        </p>
        <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">Getting Started</h2>
          <p className="text-[#6b7280]">
            Configure your agents with the principle of least privilege.
          </p>
        </div>
      </div>
    </div>
  );
}
