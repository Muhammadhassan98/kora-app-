"use client";

import { useEffect, useState } from "react";

interface Match {
  id: string;
  homeTeam: string;
  awayTeam: string;
  homeLogo: string;
  awayLogo: string;
  status: "upcoming" | "live" | "finished";
  homeScore?: number;
  awayScore?: number;
  minute?: number;
  startTime: string;
}

export default function Home() {
  const [matches, setMatches] = useState<Match[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [scores, setScores] = useState<{ [key: string]: { home: number; away: number } }>({});
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  // Stats counters
  const [stats, setStats] = useState({
    totalUsers: 1420,
    predictionsProcessed: 78,
    coinsCirculation: 28500,
  });

  useEffect(() => {
    fetchMatches();
  }, []);

  const fetchMatches = async () => {
    try {
      setLoading(true);
      const res = await fetch("http://localhost:3000/api/v1/matches");
      const data = await res.json();
      setMatches(data);

      // Initialize scores state for input
      const initialScores: typeof scores = {};
      data.forEach((m: Match) => {
        initialScores[m.id] = {
          home: m.homeScore ?? 0,
          away: m.awayScore ?? 0,
        };
      });
      setScores(initialScores);
    } catch (err) {
      console.error("Failed to fetch matches", err);
    } finally {
      setLoading(false);
    }
  };

  const handleScoreChange = (matchId: string, team: "home" | "away", val: number) => {
    setScores((prev) => ({
      ...prev,
      [matchId]: {
        ...prev[matchId],
        [team]: val,
      },
    }));
  };

  const handleProcessMatch = async (matchId: string) => {
    const matchScores = scores[matchId];
    if (!matchScores) return;

    try {
      setProcessingId(matchId);
      setStatusMessage(null);

      // 1. Process the match and reward predictions on NestJS backend
      const res = await fetch(`http://localhost:3000/api/v1/predictions/admin/process/${matchId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          homeScore: matchScores.home,
          awayScore: matchScores.away,
        }),
      });

      if (!res.ok) {
        throw new Error("Failed to process predictions");
      }

      setStatusMessage(`✅ تم تسوية المباراة ${matchId} بنجاح واحتساب نقاط التوقعات وتوزيع المكافآت للمستخدمين!`);
      
      // Update local stats counters for rich feedback
      setStats((prev) => ({
        ...prev,
        predictionsProcessed: prev.predictionsProcessed + 1,
        coinsCirculation: prev.coinsCirculation + 500,
      }));

      // Refresh matches list
      await fetchMatches();
    } catch (err) {
      console.error(err);
      setStatusMessage("❌ فشلت عملية معالجة وحساب نتائج التوقعات للمباراة.");
    } finally {
      setProcessingId(null);
    }
  };

  return (
    <div className="min-h-screen bg-zinc-950 text-white font-sans">
      {/* Header */}
      <header className="border-b border-zinc-800 bg-zinc-900/50 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="text-2xl">🏆</span>
            <h1 className="text-xl font-bold tracking-tight text-emerald-400">
              لوحة تحكم فانتكورا الإدارية · FantKora Admin
            </h1>
          </div>
          <span className="text-sm bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-3 py-1 rounded-full font-medium">
            Super Admin
          </span>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Banner message */}
        {statusMessage && (
          <div className="mb-6 p-4 rounded-xl border border-zinc-700 bg-zinc-900 text-center font-medium">
            {statusMessage}
          </div>
        )}

        {/* Stats Grid */}
        <section className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-zinc-900 border border-zinc-800 p-6 rounded-2xl">
            <span className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">إجمالي المشجعين المسجلين</span>
            <h2 className="text-3xl font-bold mt-2 text-emerald-400">{stats.totalUsers.toLocaleString()} 👤</h2>
          </div>
          <div className="bg-zinc-900 border border-zinc-800 p-6 rounded-2xl">
            <span className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">التوقعات التي تمت تسويتها</span>
            <h2 className="text-3xl font-bold mt-2 text-blue-400">{stats.predictionsProcessed.toLocaleString()} 📈</h2>
          </div>
          <div className="bg-zinc-900 border border-zinc-800 p-6 rounded-2xl">
            <span className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">العملات المتداولة بالاقتصاد</span>
            <h2 className="text-3xl font-bold mt-2 text-amber-400">{stats.coinsCirculation.toLocaleString()} 🪙</h2>
          </div>
        </section>

        {/* Matches Management */}
        <section className="bg-zinc-900 border border-zinc-800 rounded-2xl overflow-hidden">
          <div className="p-6 border-b border-zinc-800 flex items-center justify-between">
            <h3 className="font-bold text-lg text-emerald-400">إدارة وتسوية نتائج المباريات (Matches Manager)</h3>
            <button
              onClick={fetchMatches}
              className="bg-zinc-800 hover:bg-zinc-700 text-sm px-4 py-2 rounded-xl transition-all"
            >
              تحديث البيانات 🔄
            </button>
          </div>

          {loading ? (
            <div className="p-12 text-center text-zinc-400 font-medium">جاري تحميل قائمة المباريات المباشرة...</div>
          ) : (
            <div className="divide-y divide-zinc-800">
              {matches.map((match) => {
                const matchScore = scores[match.id] || { home: 0, away: 0 };
                const isUpcoming = match.status === "upcoming";
                const isFinished = match.status === "finished";

                return (
                  <div key={match.id} className="p-6 flex flex-col md:flex-row md:items-center justify-between gap-6">
                    {/* Teams block */}
                    <div className="flex items-center gap-6">
                      <div className="text-center w-24">
                        <div className="font-bold text-zinc-200">{match.homeTeam}</div>
                        <span className="text-xs text-zinc-500">مستضيف</span>
                      </div>
                      <div className="text-xl font-bold text-zinc-500">VS</div>
                      <div className="text-center w-24">
                        <div className="font-bold text-zinc-200">{match.awayTeam}</div>
                        <span className="text-xs text-zinc-500">ضيف</span>
                      </div>
                      <div className="ml-4">
                        <span
                          className={`text-xs px-2.5 py-1 rounded-full font-bold ${
                            match.status === "live"
                              ? "bg-red-500/10 text-red-400 border border-red-500/20"
                              : match.status === "finished"
                              ? "bg-zinc-500/10 text-zinc-400 border border-zinc-500/20"
                              : "bg-blue-500/10 text-blue-400 border border-blue-500/20"
                          }`}
                        >
                          {match.status.toUpperCase()}
                        </span>
                      </div>
                    </div>

                    {/* Result processing input */}
                    <div className="flex items-center gap-4">
                      {isFinished ? (
                        <div className="text-zinc-400 font-medium bg-zinc-950 px-4 py-2.5 rounded-xl border border-zinc-800">
                          النتيجة النهائية: {match.homeScore} - {match.awayScore} (تمت التسوية)
                        </div>
                      ) : (
                        <>
                          <div className="flex items-center gap-2">
                            <input
                              type="number"
                              min="0"
                              value={matchScore.home}
                              onChange={(e) =>
                                handleScoreChange(match.id, "home", parseInt(e.target.value) || 0)
                              }
                              className="w-14 bg-zinc-950 border border-zinc-800 text-center py-2 rounded-xl font-bold"
                            />
                            <span className="text-zinc-500">-</span>
                            <input
                              type="number"
                              min="0"
                              value={matchScore.away}
                              onChange={(e) =>
                                handleScoreChange(match.id, "away", parseInt(e.target.value) || 0)
                              }
                              className="w-14 bg-zinc-950 border border-zinc-800 text-center py-2 rounded-xl font-bold"
                            />
                          </div>

                          <button
                            onClick={() => handleProcessMatch(match.id)}
                            disabled={processingId !== null}
                            className="bg-emerald-500 hover:bg-emerald-600 disabled:bg-emerald-800/40 text-black font-bold px-6 py-2.5 rounded-xl transition-all text-sm"
                          >
                            {processingId === match.id ? "جاري الحساب..." : "تسوية التوقعات وتوزيع النقاط ⚡"}
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
